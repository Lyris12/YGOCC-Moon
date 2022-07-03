--Geneseed Cherrywasp
local cid,id=GetID()
function cid.initial_effect(c)
	 -- --cannot attack
   -- local e1=Effect.CreateEffect(c)
	--e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
   -- e1:SetCode(EVENT_SUMMON_SUCCESS)
  --  e1:SetOperation(cid.atklimit)
  ---  c:RegisterEffect(e1)
   -- local e2=e1:Clone()
  --  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  --  c:RegisterEffect(e2)
  --  local e3=e1:Clone()
  --  e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
  --  c:RegisterEffect(e3)  
  --attack cost
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_COST)
	e4:SetCost(cid.atcost)
	e4:SetOperation(cid.atop)
	c:RegisterEffect(e4)
  --direct attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
  --handes
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(90508760,0))
	e6:SetCategory(CATEGORY_HANDES)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(cid.condition)
	e6:SetTarget(cid.target)
	e6:SetOperation(cid.operation)
	c:RegisterEffect(e6)
end
function cid.atklimit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function cid.atcost(e,c,tp)
	return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
end
function cid.atop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,nil,REASON_DISCARD+REASON_COST)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp 
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0,nil)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
