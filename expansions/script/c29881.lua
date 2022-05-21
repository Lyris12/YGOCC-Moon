--Vassallo Doppia-Arma
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x296),2,2)
	c:EnableReviveLimit()
	--ss
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.LabelCost)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.cf(c)
	return c:IsSetCard(0x296) and c:IsAbleToRemoveAsCost()
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.cf,tp,LOCATION_GRAVE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.cf,tp,LOCATION_GRAVE,0,1,999,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_COST)>0 then
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		Duel.SetTargetParam(ct)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0,ct*300)
	end	
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetTargetParam()
	if ct and ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(ct*300)
		c:RegisterEffect(e1)
	end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:GetAttack()>c:GetAttack()
end
function s.atf(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x296) and c:IsDestructable(e,REASON_COST,tp)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(s.atf,tp,LOCATION_HAND,0,1,nil,e,tp) end
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.atf,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_COST)
	end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
end