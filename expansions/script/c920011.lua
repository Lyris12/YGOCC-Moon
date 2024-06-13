--[[
Curseflame Ancient Orias
Antica Fiammaledetta Orias
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--synchro procedure
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1,1)
	--If this card is Synchro Summoned, OR when a "Curseflame" card(s) is sent to your GY while you control this face-up card: You can target 1 monster in either GY that has a Level/Rank/Link Rating; remove Curseflame Counters on the field equal to that monster's Level/Rank/Link Rating, and if you do, Special Summon it to your field.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.SynchroSummonedCond,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	local MZChk=aux.AddThisCardInMZoneAlreadyCheck(c)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabelObject(MZChk)
	e2:SetCondition(s.spcon)
	c:RegisterEffect(e2)
	--All monsters your opponent controls that have a Curseflame Counter lose 300 ATK/DEF for each Curseflame Counter on the field.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.HasCounter,COUNTER_CURSEFLAME))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	e2:UpdateDefenseClone(c)
end

--E1
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(ARCHE_CURSEFLAME)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,s.cfilter),1,nil,tp)
end
function s.spfilter(c,e,tp)
	local lv,type=c:GetRatingAuto()
	return lv>0 and (type==0 or type&TYPE_XYZ|TYPE_LINK>0) and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_CURSEFLAME,lv,REASON_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsInGY() and s.spfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExists(true,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local lv,type=tc:GetRatingAuto()
		if not (lv>0 and (type==0 or type&TYPE_XYZ|TYPE_LINK>0)) then return end
		if Duel.RemoveCounter(tp,1,1,COUNTER_CURSEFLAME,lv,REASON_EFFECT) and tc:IsRelateToChain() then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

--E2
function s.atkval(e,c)
	return Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)*-300
end