{{- /* Fetches cluster values only once and stores them in $ */ -}}
{{- define "delphai-deployment.ensureClusterValues" -}}
  {{- if not (hasKey $ "clusterValues") -}}
    {{- $_ := set $ "clusterValues" (lookup "v1" "ConfigMap" "default" "cluster-values").data -}}
  {{- end -}}
{{- end -}}
