--[[
Galactic CODEMAN: Manipulator
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--link summon
	aux.AddLinkProcedure(c,s.mfilter,2)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:HOPT(true)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT(true)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.mfilter(c)
	return c:IsLinkRace(RACE_MACHINE) and not c:IsLinkType(TYPE_TOKEN)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(ARCHE_CODEMAN) or not c:IsAttack(c:GetBaseAttack()))
end
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CODE_JAKE)
end
function s.hspfilter(c,e,tp)
	return c:IsSetCard(ARCHE_CODE_JAKE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=c and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c)
		and Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,-2,OPINFO_FLAG_HALVE)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsFaceup() or not tc:IsRelateToChain() then return end
	local c=e:GetHandler()
	local e1,_,_,diff=tc:HalveATK(true,{c,true})
	if not tc:IsImmuneToEffect(e1) and diff<=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc2=g:GetFirst()
		if tc2 then
			Duel.SpecialSummonMod(e,tc2,0,tp,tp,false,false,POS_FACEUP_DEFENSE,nil,SPSUM_MOD_NEGATE,SPSUM_MOD_REDIRECT)
		end
	end
end

--E2
function s.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtra() and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,-2,OPINFO_FLAG_HALVE)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() then
		local c=e:GetHandler()
		local e1,_,_,diff=tc:HalveATK(true,{c,true})
		if not tc:IsImmuneToEffect(e1) and diff<=0 and c:IsRelateToChain() then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end