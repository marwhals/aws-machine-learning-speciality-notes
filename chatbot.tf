provider "aws" {
  region = "us-east-1"
}

# IAM role for Lex to call Lambda (if needed)
resource "aws_iam_role" "lex_service_role" {
  name = "LexBotRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lex.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_lexv2_bot" "chatbot" {
  name         = "SampleChatBot"
  role_arn     = aws_iam_role.lex_service_role.arn
  data_privacy {
    child_directed = false
  }
  idle_session_ttl_in_seconds = 300
  description  = "A simple chatbot built with Terraform"
  bot_locale {
    locale_id       = "en_US"
    nlu_confidence_threshold = 0.4
    voice_settings {
      voice_id = "Joanna"
    }

    intent {
      name = "GreetIntent"
      sample_utterances = ["hello", "hi", "hey"]

      intent_confirmation_setting {
        prompt_specification {
          message_groups_list {
            message {
              plain_text_message {
                value = "Would you like to continue chatting?"
              }
            }
          }
          max_retries           = 2
          allow_interrupt       = true
        }
      }

      intent_closing_setting {
        closing_response {
          message_groups_list {
            message {
              plain_text_message {
                value = "Nice chatting with you!"
              }
            }
          }
        }
      }

      fulfillment_code_hook {
        enabled = false
      }
    }
  }

  test_bot_alias_settings {
    bot_alias_locale_settings {
      locale_id = "en_US"
      enabled   = true
    }

    sentiment_analysis_settings {
      detect_sentiment = true
    }
  }

  tags = {
    Environment = "dev"
  }
}
