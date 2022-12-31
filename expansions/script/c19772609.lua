--AoJ - Il Pacemaker
--Script by XGlitchy30
function c19772609.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x197),2)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c19772609.immunetg)
	e1:SetValue(c19772609.immuneval)
	c:RegisterEffect(e1)
	--cannot tribute
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EFFECT_UNRELEASABLE_SUM)
	e11:SetValue(1)
	c:RegisterEffect(e11)
	local e111=e11:Clone()
	e111:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e111)
	--atk/def reduce + disable effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c19772609.statstg)
	e2:SetValue(c19772609.atkval)
	c:RegisterEffect(e2)
	local e22=e2:Clone()
	e22:SetCode(EFFECT_UPDATE_DEFENSE)
	e22:SetValue(c19772609.defval)
	c:RegisterEffect(e22)
	local e222=e2:Clone()
	e222:SetCode(EFFECT_DISABLE)
	e222:SetTarget(c19772609.disabletg)
	e222:SetValue(1)
	c:RegisterEffect(e222)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19772609,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c19772609.drytg)
	e3:SetOperation(c19772609.dryop)
	c:RegisterEffect(e3)
	--banish
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetOperation(c19772609.linkedprev)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(19772609,1))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_LEAVE_FIELD)
	--e5:SetCondition(c19772609.rmcon)
	e5:SetTarget(c19772609.rmtg)
	e5:SetOperation(c19772609.rmop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
--filters
--immune
function c19772609.immunetg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x197)
end
function c19772609.immuneval(e,te)
	local c=te:GetHandler()
	return c==e:GetHandler()
end
--atk/def reduce + disable effects
function c19772609.statstg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function c19772609.disabletg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
		and (c:IsType(TYPE_EFFECT) or bit.band(c:GetOriginalType(),TYPE_EFFECT)==TYPE_EFFECT)
end
function c19772609.atkval(e,c)
	return c:GetTextDefense()*-1
end
function c19772609.defval(e,c)
	return c:GetTextAttack()*-1
end
--destroy
function c19772609.drytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	local lp=Duel.GetLP(tp)/2
	local atk=tg:GetTextAttack()
	local parameter=math.abs(lp-atk)
	if chk==0 then return tg:IsOnField() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,parameter)
end
function c19772609.dryop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			local op=Duel.GetOperatedGroup():GetFirst()
			local lp=Duel.GetLP(tp)/2
			local atk=op:GetTextAttack()
			local parameter=math.abs(lp-atk)
			Duel.Damage(1-tp,parameter,REASON_EFFECT)
		end
	end
end
--banish
function c19772609.linkedprev(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetLinkedGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
--function c19772609.lkcheck(e)
--	return e:GetHandler():GetLinkedGroup():IsExists(aux.TRUE,1,nil)
--end
--function c19772609.rmcon(e,tp,eg,ep,ev,re,r,rp)
--	return c19772609.lkcheck(e)
--end
function c19772609.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end
function c19772609.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	local tc=g:GetFirst()
	local rem=Group.CreateGroup()
	while tc do
		if tc:IsAbleToRemove() then
			rem:AddCard(tc)
		end
		tc=g:GetNext()
	end
	Duel.Remove(rem,POS_FACEUP,REASON_EFFECT)
end