--Wind-Up Zenmaipulse
local s,id=GetID()
function s.initial_effect(c)
	--You can only Special Summon "Wind-Up Zenmaipulse(s)" once per turn.
	c:SetSPSummonOnce(id)
	c:EnableCounterPermit(0x14a)
	c:SetCounterLimit(0x14a,5)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.FilterEqualFunction(Card.GetVibe,0),1,1,aux.NOT(aux.FilterEqualFunction(Card.GetVibe,0)),1)
	--When this card is Bigbang Summoned: Place counters on it equal to the number of monsters with different original Types and Attributes from each other used for this card's Bigbang Summon.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetLabelObject(e0)
	e1:SetOperation(s.spcounterop)
	c:RegisterEffect(e1)
	--Each time another monster on the field activates its effect, place 1 counter on this card immediately after that effect resolves. (max. 5)
	local e02=Effect.CreateEffect(c)
	e02:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e02:SetCode(EVENT_CHAINING)
	e02:SetRange(LOCATION_MZONE)
	e02:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e02:SetOperation(s.regop)
	c:RegisterEffect(e02)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.countercon)
	e2:SetOperation(s.counterop)
	c:RegisterEffect(e2)
	--This card gains 200 ATK/DEF for each counter on it.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.attackup)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	--During your opponent's turn (Quick Effect): You can remove 5 counters from this card; destroy 1 face-up card your opponent controls.
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e5:SetCondition(s.descon)
	e5:SetCost(s.descost)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
function s.matcheck(e,c)
	local mat=c:GetMaterial()
	local dif=math.min(mat:GetClassCount(Card.GetOriginalRace), mat:GetClassCount(Card.GetOriginalAttribute))
	e:SetLabel(dif)
end
function s.spcounterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		c:AddCounter(0x14a,e:GetLabelObject():GetLabel())
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if not re:IsActiveType(TYPE_MONSTER) or re:GetHandler()==c or loc~=LOCATION_MZONE then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
function s.countercon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if not re:IsActiveType(TYPE_MONSTER) or re:GetHandler()==c or loc~=LOCATION_MZONE then return false end
	return c:GetFlagEffect(id)>0 and e:GetHandler():GetCounter(0x14a)<5
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	if c:IsFaceup() then
		c:AddCounter(0x14a,1)
	end
end
function s.attackup(e,c)
	return c:GetCounter(0x14a)*200
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x14a,5,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x14a,5,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
