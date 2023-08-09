--Number i39: Utopia Havebound

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	aux.AddXyzProcedure(c,s.matfilter,8,3)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--disable attack
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(aux.DetachSelfCost())
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.xyz_number=39
function s.matfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) or not re) then return false end
	local code,code2=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return code==CARD_RUM_DREAM_DISTILL_FORCE or code2==CARD_RUM_DREAM_DISTILL_FORCE
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		return e:GetHandler():GetOverlayGroup():IsExists(aux.MonsterFilter(Card.IsSetCard,ARCHE_UTOPIA),2,nil)
			and ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,39520,0,TYPES_TOKEN_MONSTER,3000,0,6,RACE_FAIRY,ATTRIBUTE_LIGHT)
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,39520,0,TYPES_TOKEN_MONSTER,3000,0,6,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	for i=1,ft do
		local token=Duel.CreateToken(tp,39520)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e2,true)
		end
	end
	Duel.SpecialSummonComplete()
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at and at:IsFaceup() and at:IsRelateToBattle()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	if chk==0 then
		return c:HasAttack() and a:HasAttack()
	end
	Duel.SetTargetCard(a)
	local ap,aloc=c:GetControler(),c:GetLocation()
	if a:HasAttack() then
		Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,a,1,ap,aloc,a:GetBaseAttack())
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		local c=e:GetHandler()
		local tc=Duel.GetAttacker()
		if c:IsFaceup() and c:IsRelateToChain() and c:HasAttack() and tc and tc:IsRelateToChain() and tc:IsFaceup() and tc:HasAttack() then
			Duel.BreakEffect()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end