--Dark World Queen of Evil Vine
function c160002496.initial_effect(c)
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),aux.Tuner(nil),nil,aux.FilterBoolFunction(Card.c:IsSetCard,0x485a),1,1)
	c:EnableReviveLimit()
c:EnableReviveLimit()
		--spsummon condition
	local e69=Effect.CreateEffect(c)
	e69:SetType(EFFECT_TYPE_SINGLE)
	e69:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e69:SetCode(EFFECT_SPSUMMON_CONDITION)
	e69:SetValue(c160002496.splimit)
	c:RegisterEffect(e69)
--negate
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(160002496,0))
e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
e1:SetCode(EVENT_CHAINING)
e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
e1:SetRange(LOCATION_MZONE)
e1:SetCountLimit(1)
e1:SetCondition(c160002496.condition)
e1:SetTarget(c160002496.target)
e1:SetOperation(c160002496.operation)
c:RegisterEffect(e1)
--destroy
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(160002496,0))
e2:SetCategory(CATEGORY_DESTROY)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
e2:SetCode(EVENT_SPSUMMON_SUCCESS)
e2:SetCondition(c160002496.descon)
e2:SetTarget(c160002496.destg)
e2:SetOperation(c160002496.desop)
c:RegisterEffect(e2)



		--spsummon count limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	 e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetTarget(c160002496.sumlimit)
	c:RegisterEffect(e4)

   local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(160002496)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
--  e5:SetCondition(c160002496.con)
	e5:SetTargetRange(0,1)
	c:RegisterEffect(e5)
	if c160002496.global_check==nil then
		c160002496.global_check=true
		c160002496[0]=1
		c160002496[1]=1
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(c160002496.resetop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetOperation(c160002496.checkop)
		Duel.RegisterEffect(ge2,0)
	end

		local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(c160002496.syncon)
	e0:SetOperation(c160002496.synop)
	e0:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e0)
		 local e34=Effect.CreateEffect(c)
	e34:SetType(EFFECT_TYPE_SINGLE)
	e34:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e34:SetRange(LOCATION_MZONE)
	e34:SetCode(EFFECT_IMMUNE_EFFECT)
	e34:SetValue(c160002496.efilter)
	c:RegisterEffect(e34)
end
function c160002496.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
function c160002496.condition(e,tp,eg,ep,ev,re,r,rp)
return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function c160002496.xcostfilter(c)
return c:IsRace(RACE_FIEND)
end
function c160002496.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then return true end
	if chk==0 then return Duel.IsExistingMatchingCard(c160002496.xcostfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c160002496.dissfilter(c)
	return c:IsRace(RACE_FIEND)
end
function c160002496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c160002496.dissfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function c160002496.operation(e,tp,eg,ep,ev,re,r,rp)
  if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(tp,c160002496.dissfilter,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		end
	end
end


function c160002496.descon(e,tp,eg,ep,ev,re,r,rp)
return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function c160002496.filter(c,atk)
return  not c:IsAbleToHandAsCost()
	and not c:IsType(TYPE_SYNCHRO)
	and c:IsAbleToRemove()
	and not c:IsType(TYPE_TOKEN)
end
function c160002496.destg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(c160002496.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
local sg=Duel.GetMatchingGroup(c160002496.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,sg:GetCount(),0,0)

end

function c160002496.filter1(c)
return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_WATER+ATTRIBUTE_EARTH) and c:IsLocation(LOCATION_GRAVE)
end
function c160002496.desop(e,tp,eg,ep,ev,re,r,rp)
local sg=Duel.GetMatchingGroup(c160002496.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	  Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
--local og=Duel.GetOperatedGroup()
--local dc=og:FilterCount(c160002496.filter1,nil)
--if dc>0 then
--Duel.BreakEffect()
--Duel.Damage(1-tp,dc*500,REASON_EFFECT)
end
function c160002496.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return  not c:IsAbleToHandAsCost()
	and not c:IsType(TYPE_SYNCHRO)
	and not c:IsType(TYPE_TOKEN)
	and c160002496[sump]<=0
end


function c160002496.resetop(e,tp,eg,ep,ev,re,r,rp)
	c160002496[0]=1
	c160002496[1]=1
end
function c160002496.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_EXTRA) then
			local p=tc:GetSummonPlayer()
			c160002496[p]=c160002496[p]-1
		end
		tc=eg:GetNext()
	end
end



function c160002496.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP+TYPE_SPELL) and te:GetOwner()~=e:GetOwner()
end