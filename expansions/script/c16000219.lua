--Bloom Maiden of Fiber Vine
function c16000219.initial_effect(c)
--pendulum summon
   
	c:EnableReviveLimit()

	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16000219,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
   e1:SetCondition(c16000219.descon)
	e1:SetTarget(c16000219.destg)
	e1:SetOperation(c16000219.desop)
	c:RegisterEffect(e1)
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetDescription(aux.Stringid(16000219,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c16000219.condition2)
	e2:SetCost(c16000219.cost2)
	e2:SetTarget(c16000219.target)
	e2:SetOperation(c16000219.operation2)
	c:RegisterEffect(e2)

--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x185a))
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	   local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	
end

function c16000219.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x185a) or  c:IsRace(RACE_PLANT)  then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function c16000219.splimcon(e)
	return not e:GetHandler():IsForbidden()
end
function c16000219.condition2(e,tp,eg,ep,ev,re,r,rp)
			local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if tc:IsSetCard(0x185a) and bit.band(bc:GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL then
		e:SetLabelObject(bc)
		return true
	else return false end
end
function c16000219.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	   local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c16000219.cfilter2(c)
	return c:IsFaceup()
end
function c16000219.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return e:GetHandler():IsDestructable()
and Duel.IsExistingMatchingCard(c16000219.cfilter2,tp,0,LOCATION_MZONE,1,nil) end
end
function c16000219.operation2(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c16000219.cfilter2,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

function c16000219.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bit.band(bc:GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL
end
function c16000219.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler():GetBattleTarget(),1,0,0)
end
function c16000219.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end


function c16000219.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return re~=e:GetLabelObject()
end
function c16000219.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c16000219.cfilter,tp,LOCATION_EXTRA,0,1,e:GetHandler()) end
	local g=Duel.GetMatchingGroup(c16000219.cfilter,tp,LOCATION_EXTRA,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c16000219.dkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_EXTRA,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end

function c16000219.cfilter(c)
	return c:IsFaceup() and  c:IsSetCard(0x185a)  and c:IsAbleToDeck()
end

end
function c16000219.indtg(e,c)
	return c:IsSetCard(0x185a)
end