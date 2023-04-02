--Galadia, Lightsworn Enigma
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,s.matfilter1,1,1,s.matfilter2,1)
	--If this card is Bigbang Summoned: You can send cards from the top of your Deck to the GY up to the number of Bigbang Materials used for the Bigbang Summon of this card.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetLabelObject(e0)
	e1:SetCondition(s.ddescon)
	e1:SetTarget(s.ddestg)
	e1:SetOperation(s.ddesop)
	c:RegisterEffect(e1)
	--Gains 300 ATK for each monster with different name in your GY.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	--You can discard 1 card, then target 1 face-up card your opponent controls; banish it.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(aux.NOT(s.rmquickcon))
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCondition(s.rmquickcon)
	c:RegisterEffect(e4)
end
function s.matfilter1(c)
	return c:IsNeutral() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.matfilter2(c)
	return not c:IsNeutral() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.ddescon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function s.ddestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ddes=e:GetHandler():GetMaterialCount()
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ddes) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ddes)
end
function s.ddesop(e,tp,eg,ep,ev,re,r,rp)
	local ddes=e:GetHandler():GetMaterialCount()
	Duel.DiscardDeck(tp,ddes,REASON_EFFECT)
end
function s.value(e,c)
	local g=Duel.GetMatchingGroup(Card.IsMonster,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*300
end
function s.rmquickcon(e,tp,eg,ep,ev,re,r,rp)
	c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsMonster,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetRace)
	return ct>3
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end