module Test.Hspec.ExpectationsSpec (main, spec) where

import           Test.Hspec.HUnit()
import           Test.Hspec (Spec, describe, it)
import           Test.Hspec.Runner
import           Test.HUnit
import           Control.Exception
import           System.IO.Silently

import           Test.Hspec.Expectations

main :: IO ()
main = hspec spec

shouldResultIn :: Assertion -> String -> IO ()
shouldResultIn expectation result = do
  r <- fmap (last . lines) . capture_ . hspecWith defaultConfig $ do
    it "" expectation
  r @?= result

shouldHold :: Assertion -> Assertion
shouldHold = (`shouldResultIn` "1 example, 0 failures")

shouldNotHold :: Assertion -> Assertion
shouldNotHold = (`shouldResultIn` "1 example, 1 failure")

spec :: Spec
spec = do
  describe "shouldBe" $ do
    it "succeeds if arguments are equal" $ do
      shouldHold $
        "foo" `shouldBe` "foo"

    it "fails if arguments are not equal" $ do
      shouldNotHold $
        "foo" `shouldBe` "bar"

  describe "shouldSatisfy" $ do
    it "succeeds if value satisfies predicate" $ do
      shouldHold $
        "" `shouldSatisfy` null

    it "fails if value does not satisfy predicate" $ do
      shouldNotHold $
        "foo" `shouldSatisfy` null

  describe "shouldReturn" $ do
    it "succeeds if arguments represent equal values" $ do
      shouldHold $
        return "foo" `shouldReturn` "foo"

    it "fails if arguments do not represent equal values" $ do
      shouldNotHold $
        return "foo" `shouldReturn` "bar"

  describe "shouldThrow" $ do
    it "can be used to require a specific exception" $ do
      shouldHold $
        throw DivideByZero `shouldThrow` (== DivideByZero)

    it "can be used to require any exception" $ do
      shouldHold $
        error "foobar" `shouldThrow` anyException

    it "can be used to require an exception of a specific type" $ do
      shouldHold $
        error "foobar" `shouldThrow` anyErrorCall

    it "can be used to require a specific exception" $ do
      shouldHold $
        error "foobar" `shouldThrow` errorCall "foobar"

    it "fails, if a required specific exception is not thrown" $ do
      shouldNotHold $
        throw Overflow `shouldThrow` (== DivideByZero)

    it "fails, if any exception is required, but no exception occurs" $ do
      shouldNotHold $
        return () `shouldThrow` anyException

    it "fails, if a required exception of a specific type is not thrown" $ do
      shouldNotHold $
        return () `shouldThrow` anyErrorCall

    it "fails, if a required specific exception is not thrown" $ do
      shouldNotHold $
        error "foo" `shouldThrow` errorCall "foobar"
