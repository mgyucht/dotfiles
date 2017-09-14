#!/usr/bin/env lein-exec

(def default-namespace-for-environment
  {:dev "development"
   :staging "staging"
   :prod "production"})
(def aws-namespaces
  {"vault" "v"
   "central-vault" "cv"
   "default" "d"
   "accounts" "a"})
(def azure-namespaces {"accounts" "a"})
(def region-abbreviations
  {"westus" "wu"
   "eastus" "eu"
   "eastus2" "eu2"
   "westeurope" "we"})
(def region-config
  {:aws {:dev {:regions ["us-west-2"]}
         :staging {:regions ["us-west-2"]}
         :prod {:regions ["us-west-2"]}}
   :azure {:dev {:regions ["westus", "eastus"]}
           :staging {:regions ["westus"]}
           :prod {:regions ["westus", "eastus2", "westeurope"]}}})

(defn namespace-config
  [cloud env]
  (merge {(default-namespace-for-environment env) ""}
        (case cloud
          :aws aws-namespaces
          :azure azure-namespaces)))

(defn region-abbrev
  [region-kw]
  (get region-abbreviations region-kw (name region-kw)))

(defn get-alias
  [cloud env region ns-abbrev]
  (let [prefix (first (name env))
        cloud-and-region-infix (case cloud
                                 :azure (str "a" (region-abbrev region))
                                 :aws "")]
    (str "k" prefix cloud-and-region-infix ns-abbrev)))

(defn get-context-and-namespace
  [cloud env region ns]
  (let [context (case cloud
                  :aws (name env)
                  :azure (str (name env) "-" (name cloud) "-" region))]
    (str "--context=" (name context) " --namespace=" ns)))

(def generate-mappings
  (for [cloud (keys region-config)
        env (keys (region-config cloud))
        region ((get-in region-config [cloud env]) :regions)
        ns-map (namespace-config cloud env)]
    {:alias (get-alias cloud env region (second ns-map))
     :flags (get-context-and-namespace cloud env region (first ns-map))}))

(defn mapping-to-alias
  [{:keys [alias flags]}]
  (str "alias " alias "=\"kubecfg " flags "\""))

(def alias-filename (str (System/getProperty "user.home") "/dotfiles/autogen/kubecfg-aliases.sh"))
(def preamble
  (str "#!/usr/bin/env sh\n"
       "# NOTE: this file is autogenerated. Do not edit this; instead, modify generate-kubecfg-aliases.cfg.\n\n"))
(def aliases (clojure.string/join "\n" (map mapping-to-alias generate-mappings)))
(def alias-file (str preamble aliases))

(println "Writing alias file to" alias-filename)
(spit alias-filename alias-file)
