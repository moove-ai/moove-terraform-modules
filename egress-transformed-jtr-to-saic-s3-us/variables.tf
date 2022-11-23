variable label {
  type        = map(string)
  default = {
    function = "data-pipelines"
    pipeline = "join-to-roads"
    component = "egress"
    client = "saic"
  }
  description = "description"
}
