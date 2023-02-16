--Symphaerie Lead, Cili
local ref,id=GetID()
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--Starting Choord
	local pe1=Effect.CreateEffect(c)
	pe1:SetCategory(CATEGORY_DESTROY)
	pe1:SetType(EFFECT_TYPE_IGNITION)
	pe1:SetCode(EVENT_FREE_CHAIN)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCountLimit(1)
	pe1:SetCost(ref.setcost)
	pe1:SetTarget(ref.settg)
	pe1:SetOperation(ref.setop)
	c:RegisterEffect(pe1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,ref.counterfilter)
	--Proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(ref.spcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e2)
	--Place
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(ref.sccost)
	e3:SetTarget(ref.sctg)
	e3:SetOperation(ref.scop)
	c:RegisterEffect(e3)
end

--Set
function ref.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO+TYPE_PENDULUM)
end
function ref.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(ref.sslimit)
	Duel.RegisterEffect(e1,tp)
end
function ref.sslimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO+TYPE_PENDULUM)
end
function ref.setfilter(c) return c:IsSetCard(0x255) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function ref.setop(e,tp,eg,ep,ev,re,r,rp) local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g)~=0 and c:IsRelateToEffect(e) then Duel.Destroy(c,REASON_EFFECT) end
end

--Proc
function ref.spfilter(c) return c:IsFaceup() and c:IsSetCard(0x255) end
function ref.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(ref.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not c:IsLocation(LOCATION_EXTRA))
		or Duel.GetLocationCountFromEx(tp)>0)
end

--Place
function ref.sccost(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_ONFIELD,0,1,nil) 
		and c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_MZONE) then Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	else Duel.ChangePosition(tc,POS_FACEDOWN) end
end
function ref.scfilter(c)
	return c:IsSetCard(0x255) and c:IsType(TYPE_PENDULUM) and not (c:IsForbidden() or c:IsCode(id))
end
function ref.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(ref.scfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function ref.scop(e,tp)
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,ref.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true) end
end

