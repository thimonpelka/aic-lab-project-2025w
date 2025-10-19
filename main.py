#!/usr/bin/env python3
import os
from aws_cdk import App, Environment
from infrastructure.stack import ELearningStack

app = App()

is_local = app.node.try_get_context("local") == "true"

ELearningStack(
    app,
    "ELearningStack",
    env=Environment(
        account=os.getenv("CDK_DEFAULT_ACCOUNT", "000000000000"),
        region=os.getenv("CDK_DEFAULT_REGION", "eu-west-1"),
    ),
    is_local=is_local,
)

app.synth()
