--[[
Number i211: Invernal of the Mirror Shield
Numero i211: Invernale dello Scudo Specchio
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 Level 6 "Invernal" monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,ARCHE_INVERNAL),6,2)
	--[[If this card is Xyz Summoned: You can target 1 Reptile monster in your GY; negate the effects of all monsters your opponent currently controls with a lower ATK than that monster's.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[When your opponent activates a card or effect (Quick Effect): You can detach 1 material from this card; negate the activation.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.discon)
	e2:SetCost(aux.DetachSelfCost())
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--[[Your opponent's monsters cannot target for attacks, and your opponent cannot target with card effects, any monster you control, except this card.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.tglimit)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.tglimit)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
aux.xyz_number[id]=211

--E1
function s.filter(c,g)
	local atk=c:GetAttack()
	return c:IsRace(RACE_REPTILE) and atk>0 and g:IsExists(Card.IsAttackBelow,1,nil,atk-1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,g) end
	if chk==0 then
		return #g>0 and Duel.IsExists(true,s.filter,tp,LOCATION_GRAVE,0,1,nil,g)
	end
	local tg=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,g)
	local dg=g:Filter(Card.IsAttackBelow,nil,tg:GetFirst():GetAttack()-1)
	Duel.SetCardOperationInfo(dg,CATEGORY_DISABLE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsMonster() then
		local atk=tc:GetAttack()
		if atk<=0 then return end
		local g=Duel.Group(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e):Filter(Card.IsAttackBelow,nil,atk-1)
		if #g>0 then
			Duel.Negate(g,e,0,false,false,TYPE_MONSTER)
		end
	end
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

--E4
function s.tglimit(e,c)
	return c~=e:GetHandler()
end