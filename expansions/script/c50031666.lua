--Supa-Pittrice Goghi Raggiante
--XGlitchy30 was here
local cid,id=GetID()
function cid.initial_effect(c)
	--evolute procedure
	aux.EnablePendulumAttribute(c)
	aux.AddOrigEvoluteType(c)
	aux.AddEvoluteProc(c,nil,4,cid.filter1,1,cid.filter2,1)
	c:EnableReviveLimit()
	--PENDULUM EFFECTS
	--active limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(cid.actcon)
	e3:SetOperation(cid.actop)
	c:RegisterEffect(e3)
	--gain ATK
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(cid.condition)
	e4:SetOperation(cid.op)
	c:RegisterEffect(e4)
	--MONSTER EFFECTS
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(cid.atkcon)
	e1:SetCost(cid.atkcost)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
	--wipe field
  --  local e5=Effect.CreateEffect(c)
  --  e5:SetDescription(aux.Stringid(id,0))
  --  e5:SetCategory(CATEGORY_TOGRAVE)
  --  e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
  --  e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  --  e5:SetCode(EVENT_SPSUMMON_SUCCESS)
  --  e5:SetCondition(cid.sgcon)
  --  e5:SetTarget(cid.sgtg)
--  e5:SetOperation(cid.sgop)
   -- c:RegisterEffect(e5)
	--actlimit
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(0,1)
	e6:SetValue(cid.aclimit2)
	e6:SetCondition(cid.actcon2)
	c:RegisterEffect(e6)
	--pendulum
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,5))
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_DESTROYED)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCondition(cid.pencon)
	e7:SetTarget(cid.pentg)
	e7:SetOperation(cid.penop)
	c:RegisterEffect(e7)
end
--enable pendulum level
cid.pendulum_level=4
--filters
function cid.checku(sg,ec,tp)
return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function cid.filter1(c,ec,tp)
	return c:IsRace(RACE_FAIRY) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cid.filter2(c,ec,tp)
	return not c:IsType(TYPE_EFFECT)
end
function cid.nmfilter(c)
	return  c:IsType(TYPE_NORMAL) and c:IsFaceup()
end
function cid.filter(c)
	return c:IsFaceup() and (c:GetLevel()>=5 or c:GetRank()>=5) and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
		and c:GetSummonType()&SUMMON_TYPE_SPECIAL==SUMMON_TYPE_SPECIAL
end
function cid.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
function cid.atkfilter(c)
	return bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL  and c:IsType(TYPE_EFFECT)
end
function cid.costfilter(c)
	return c:IsAbleToRemoveAsCost() and not c:IsType(TYPE_EFFECT) and (c:IsType(TYPE_PENDULUM) and c:IsFaceup())
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0xc50) or c:IsType(TYPE_NORMAL) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function cid.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
--PENDULUM EFFECTS
--active limit
function cid.actcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	return ac and ac:IsControler(tp) and not ac:IsType(TYPE_EFFECT)
end
function cid.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetTargetRange(0,1)
	e1:SetValue(cid.actlimit)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e1)
end
function cid.actlimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
--gain ATK
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then return end
	e:SetLabelObject(bc)
	return bc:IsFaceup() and tc:IsFaceup() and not tc:IsType(TYPE_EFFECT)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsFaceup() and bc:IsControler(1-tp) then
		local val=bc:GetAttack()
		if val<=0 then val=0 end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		e1:SetValue(val)
		Duel.GetAttacker():RegisterEffect(e1)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetOperation(cid.damop)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
function cid.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(1-tp,0)
end
---MONSTER EFFECTS
--wipe field
function cid.sgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388
end
function cid.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function cid.sgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if ct>0 then
			Duel.BreakEffect()
			Duel.SetLP(tp,Duel.GetLP(tp)-ct*500)
		end
	end
end
--actlimit
function cid.aclimit2(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function cid.actcon2(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
--atk
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
function cid.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,2,REASON_COST) and Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil) and c:GetFlagEffect(id)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetHandler():RemoveEC(tp,2,REASON_COST)
	c:RegisterFlagEffect(id,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cid.atkfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local atk=0
		local tc=g:GetFirst()
		while tc do
			atk=atk+tc:GetAttack()/2
			tc=g:GetNext()
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end


function cid.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function cid.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function cid.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end


--function cid.spcon(e,c)
	--if c==nil then return true end
--  local tp=c:GetControler()
--  local g1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,160007854)
--  if g1:GetCount()>0 then
--  local g2=Duel.IsCanRemoveCounter(c:GetControler(),1,1,0x1075,4,REASON_COST)
	--  return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and g2
--  end
--  return false
--end
--function cid.spop(e,tp,eg,ep,ev,re,r,rp,c)
--  local g1=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_MZONE,0,1,1,nil,160007854)
--  local g2=Duel.RemoveCounter(tp,1,1,0x1075,4,REASON_RULE)
--  Duel.SendtoGrave(g1,REASON_MATERIAL+REASON_SYNCHRO)
--end
