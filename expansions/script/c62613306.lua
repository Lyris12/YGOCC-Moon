--Waltz, la Nottesfumo Ascensione
--Script by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,ARCHE_NIGHTSHADE),aux.NonTuner(Card.IsSetCard,ARCHE_NIGHTSHADE),1)
	c:EnableReviveLimit()
	--add or return
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOGRAVE|CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:HOPT()
	e0:SetFunctions(s.singlecon,nil,s.target,s.operation)
	c:RegisterEffect(e0)
	e0:SpecialSummonEventClone(c)
	e0:FlipSummonEventClone(c)
	local e1=e0:Clone()
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetFunctions(s.fieldcon,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
--filters
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(ARCHE_NIGHTSHADE) and c:IsSummonPlayer(tp)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
--special summon
function s.singlecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonPlayer(tp)
end
function s.fieldcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.rmfilter(chkc) end
	if chk==0 then
		return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil)
	end
	local g=Duel.Select(HINTMSG_OPERATECARD,true,tp,s.rmfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		if tc:IsAbleToHand() and Duel.SelectOption(tp,STRING_ADD_TO_HAND,STRING_SEND_TO_GY)==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tc:GetControler(),tc)
		else
			Duel.SendtoGrave(tc,REASON_EFFECT|REASON_RETURN)
		end
	end
end