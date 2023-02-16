--Deptheaven's Blessings
local ref,id=GetID()
Duel.LoadScript("Deptheaven.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	--Grant
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(ref.immcon)
	e2:SetValue(ref.efilter)
	c:RegisterEffect(e2)
end

function ref.seqfilter(c) return Deptheaven.Is(c) and Deptheaven.LeftRightCheck(c) end
function ref.thfilter(c,e,tp)
	if c:IsCode(id) or not c:IsAbleToHand() then return false end
	return Deptheaven.Is(c) or (Duel.GetMatchingGroupCount(ref.seqfilter,tp,LOCATION_SZONE+LOCATION_PZONE,0,e:GetHandler())==2
		and c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_LIGHT) and c:IsLevel(4))
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function ref.thop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then Duel.ConfirmCards(1-tp,g) end
end

function ref.immcon(e)
	return Deptheaven.Is(e:GetHandler())
end
function ref.efilter(e,te)
	if te:GetHandlerPlayer()==e:GetHandlerPlayer() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
