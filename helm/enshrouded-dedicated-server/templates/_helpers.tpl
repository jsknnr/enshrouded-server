{{- define "enshrouded.passwordSecretName" -}}
{{- if .Values.config.serverPasswordExistingSecretName -}}
{{ .Values.config.serverPasswordExistingSecretName -}}
{{- else -}}
{{ .Release.Name }}-password
{{- end -}}
{{- end -}}
