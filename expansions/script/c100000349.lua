--[[
Number 207: Manaseal Archon
Numero 207: Arconte Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ Level 8 monsters
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	--[[If this card is Xyz Summoned, or if the activation or effect of a Spell Card(s) is negated while you control this monster (Quick Effect): You can declare 1 Spell Card name; the next time your
	opponent resolves an activated Spell Card or effect with the same original name as the declared one, that activated effect becomes the following effect. ● Your opponent draws 2 cards, then you
	must banish 1 random card from your face-down Extra Deck, face-down.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.XyzSummonedCond,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.condition)
	c:RegisterEffect(e3)
	local e3=e3:Clone()
	e3:SetCode(EVENT_CHAIN_DISABLED)
	c:RegisterEffect(e3)
	--[[At the start of your opponent's Standby Phase (Quick Effect): You can detach 1 material from this card; for the rest of this turn, if your opponent would activate a Spell Card or effect, they
	must pay 400 LP x the combined number of Trap Cards in both player's GYs with different original names from each other.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_PHASE_START|PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:OPT()
	e4:SetCondition(aux.StandbyPhaseCond(1))
	e4:SetOperation(s.raise)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(id,3)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CUSTOM+id)
	e5:SetRange(LOCATION_MZONE)
	e5:HOPT()
	e5:SetFunctions(
		s.paycon,
		aux.DetachSelfCost(),
		nil,
		s.payop
	)
	c:RegisterEffect(e5)
end
aux.xyz_number[id]=207

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	getmetatable(e:GetHandler()).announce_filter={TYPE_SPELL,OPCODE_ISTYPE}
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=Duel.GetTargetParam()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:OPT()
	e1:SetLabel(ac)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	Duel.RegisterEffect(e1,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsOriginalCodeRule(e:GetLabel())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
	e:Reset()
end
function s.rmfilter(c,tp)
	return c:IsFacedown() and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_RULE)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(1-tp,2,REASON_EFFECT)>0 then
		local g=Duel.Group(s.rmfilter,tp,LOCATION_EXTRA,0,nil,tp)
		if #g>0 then
			local rg=g:RandomSelect(tp,1)
			Duel.Remove(rg,POS_FACEDOWN,REASON_RULE)
		end
	end
end

--E2
function s.raise(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
end

--E3
function s.paycon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:GetFirst()==e:GetHandler() and not Duel.CheckPhaseActivity()
end
function s.payop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE|PHASE_END,0,1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,4)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetTargetRange(0,1)
	e2:SetCost(s.costchk)
	e2:SetTarget(s.costtg)
	e2:SetOperation(s.costop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.costchk(e,te_or_c,tp)
	local g=Duel.Group(Card.IsTrap,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g==0 then return true end
	local i=Duel.GetFlagEffect(tp,id)
	local j=g:GetClassCount(Card.GetOriginalCodeRule)
	return Duel.CheckLPCost(tp,i*j*400)
end
function s.costtg(e,te,tp)
	return te:IsActiveType(TYPE_SPELL)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsTrap,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	local j=g:GetClassCount(Card.GetOriginalCodeRule)
	if j==0 then return end
	Duel.PayLPCost(tp,j*400)
end