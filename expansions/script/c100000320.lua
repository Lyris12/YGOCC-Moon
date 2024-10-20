--[[
Unity of the Invernal
Unità degli Invernali
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When this card is activated: You can send DARK Reptile monsters from your Deck to the GY, up to the number of cards your opponent controls.]]
	local e1=c:Activation(true,nil,nil,nil,s.target,s.activate,true)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	c:RegisterEffect(e1)
	--[["Invernal" monsters you control can attack a number of times each Battle Phase, up to the number of "Invernal" monsters you control.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_INVERNAL))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--[[Once per turn: You can target 1 "Invernal" monster in your GY or banishment; shuffle it into the Deck, and if you do, send the top card of your Deck to the GY.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,0)
	e3:SetCategory(CATEGORY_TODECK|CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return c:IsAttributeRace(ATTRIBUTE_DARK,RACE_REPTILE) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local max=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if max==0 or #g==0 or not Duel.SelectYesNo(tp,STRING_ASK_TO_GRAVE) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:Select(tp,1,max,nil)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end

--E2
function s.atkval(e)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,ARCHE_INVERNAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return ct-1
end

--E3
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_INVERNAL) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GB) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.tdfilter,tp,LOCATION_GB,0,1,nil) and Duel.IsPlayerCanDiscardDeck(tp,1)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GB,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.ShuffleIntoDeck(tc)>0 then
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
	end
end