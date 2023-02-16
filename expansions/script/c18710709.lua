--Zere Assoluto del Mare
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special summon limitation
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	--Immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.etg)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	local e3x=e3:Clone()
	e3x:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3x:SetValue(1)
	c:RegisterEffect(e3x)
	--Reduce Damage
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.rdcon)
	e4:SetOperation(s.rdop)
	c:RegisterEffect(e4)
	--Reduce stats, negate
	local e5=Effect.CreateEffect(c)
	e5:Desc(2)
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetCountLimit(1,id)
	e5:SetCondition(s.sscon)
	e5:SetTarget(s.sstg)
	e5:SetOperation(s.ssop)
	c:RegisterEffect(e5)
	local e5x=e5:Clone()
	e5x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5x)
	local e5y=e5:Clone()
	e5y:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5y)
end
function s.spcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(aux.Faceup(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
	if #rg<=0 then return false end
	local _,atk=rg:GetMaxGroup(Card.GetAttack)
	local _,def=rg:GetMaxGroup(Card.GetDefense)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE) 
	return ft>0 and (atk>0 or def>0) and Duel.CheckLPCost(tp,math.max(atk,def))
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.Faceup(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	local _,atk=g:GetMaxGroup(Card.GetAttack)
	local _,def=g:GetMaxGroup(Card.GetDefense)
	local val=math.max(atk,def)
	if val<=0 then return end
	Duel.PayLPCost(tp,val)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
	end
	g:DeleteGroup()
end

function s.etg(e,c)
	return c:IsAttack(0) and c:IsDefense(0) and c:IsMonster() and c~=e:GetHandler()
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.rdcon(e)
	local tp=e:GetHandlerPlayer()
	local a=Duel.GetAttacker()
	local b=Duel.GetAttackTarget()
	return a:IsControler(tp) and a:IsAttack(0) and a:IsDefense(0) or b~=nil and b:IsControler(tp) and b:IsAttack(0) and b:IsDefense(0)
end
function s.cf(c)
	return c:IsAttack(0) and c:IsDefense(0) and c:IsMonster()
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(tp)
	local ct=Duel.GetMatchingGroupCount(aux.Faceup(s.cf),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct<=0 or dam<=0 then return end
	dam=dam-(ct*1000)
	Duel.ChangeBattleDamage(tp,math.max(dam,0))
end

function s.cfilter(c,disable)
	return c:IsMonster() and (c:GetAttack()>0 or c:GetDefense()>0)
end
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.Faceup(s.cfilter),1,nil)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(aux.Faceup(s.cfilter),nil)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,0,#g,nil) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,#g,tp,LOCATION_ONFIELD)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(aux.Faceup(s.cfilter),nil)
	for tc in aux.Next(g) do
		local atk,def=tc:GetAttack(),tc:GetDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
		if tc:GetAttack()==0 and tc:GetDefense()==0 and (atk>0 and not tc:IsImmuneToEffect(e1) or def>0 and not tc:IsImmuneToEffect(e2)) and aux.NegateAnyFilter(tc) then
			Duel.Negate(tc,e)
		end
	end
	if not Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,0,#g,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local dg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,0,#g,#g,nil)
	if #dg>0 then
		Duel.HintSelection(dg)
		for tc in aux.Next(dg) do
			Duel.Negate(tc,e)
		end
	end
end