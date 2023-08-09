--Number i39: Utopia Magias

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,1,99)
	--change name
	aux.EnableChangeCode(c,CARD_NUMBER_39_UTOPIA,LOCATION_MZONE|LOCATION_GRAVE)
	--attack
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_ATKDEF|CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetCost(aux.DetachSelfCost())
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
s.xyz_number=39

function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,4)
end
function s.xyzcheck(g)
	local ct=#g+(2*g:FilterCount(Card.IsHasEffect,nil,39506))
	return ct>=3
end

--E1
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at and at:IsRelateToBattle()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	local a=Duel.GetAttacker()
	Duel.SetTargetCard(a)
	local ap,aloc=a:GetControler(),a:GetLocation()
	if a:HasAttack() then
		Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,a,1,ap,aloc,{math.ceil(a:GetAttack()/2)})
	end
	if a:HasDefense() then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DEFCHANGE,a,1,ap,aloc,{math.ceil(a:GetDefense()/2)})
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,a,1,ap,aloc)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if not tc then return end
	local b1=tc:IsFaceup() and tc:IsRelateToChain()
	local opt=aux.Option(Duel.GetTurnPlayer(),id,1,b1,true)
	if not opt then return end
	if opt==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=e1:SetDefenseFinalClone(tc,true)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		tc:RegisterEffect(e2)
		if tc:IsCanBeDisabledByEffect(e) then
			Duel.Negate(tc,e,{RESET_PHASE|PHASE_END,2})
		end
	elseif opt==1 then
		Duel.NegateAttack() 
		if tc and tc:IsRelateToChain() and (tc:IsFacedown() or not tc:IsSetCard(ARCHE_UTOPIA)) and tc:IsCanBeDisabledByEffect(e) then
			Duel.Negate(tc,e,{RESET_PHASE|PHASE_END,2})
		end
	end
end
