--Lily the Flame Esprision
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--When this card is Normal Summoned: You can target 1 "Esprision" monster in your GY; Special Summon it.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--An Xyz Monster that was Summoned using this card on the field as material gains this effect.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
s.toss_coin=true

function s.filter(c,e,tp)
	return c:IsSetCard(0xe50) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&REASON_XYZ~=0 and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetReasonCard():IsType(TYPE_XYZ)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--[[Once per turn: You can detach 1 material from this card; toss a coin and if the result is heads,
	Special Summon 1 "Esprision" monster from your GY, or if the result is tails, Special Summon 1 "Esprision" monster from your hand.]]
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_COIN|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.DetachSelfCost())
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	rc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local coin=Duel.TossCoin(tp,1)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local loc = coin==COIN_HEADS and LOCATION_GRAVE or coin==COIN_TAILS and LOCATION_HAND or 0
	Duel.HintMessage(tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,loc,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end