--[[
Curseflame Ancient Beau
Antica Fiammaledetta Beau
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),5,2,nil,nil,99)
	--[[If this card is Xyz Summoned: You can activate this effect; move all Curseflame Counters on the field onto this card (min. 3), and if you do, destroy all other cards on the field, except "Curseflame" cards you control. Cards destroyed by this effect cannot activate their effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_COUNTER|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--Once per turn (Quick Effect): You can detach 1 material from this card, OR remove 3 Curseflame Counters from this card; inflict 300 damage to your opponent for each Curseflame Counter on the field. If your opponent's LP would become 0 because of this effect, their LP becomes 300 instead.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		s.damcon,
		s.damcost,
		s.damtg,
		s.damop
	)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		ge:SetCode(EFFECT_CANNOT_LOSE_KOISHI)
		ge:SetCondition(s.regcon)
		ge:SetTargetRange(1,0)
		ge:SetValue(1)
		Duel.RegisterEffect(ge,0)
		local ge2=ge:Clone()
		Duel.RegisterEffect(ge2,1)
	end
end
function s.regcon(e)
	return Duel.PlayerHasFlagEffect(e:GetOwnerPlayer(),id)
end
--E1
function s.excfilter(c,tp)
	return c:IsFacedown() or not c:IsControler(tp) or not c:IsSetCard(ARCHE_CURSEFLAME)
end
function s.gcheck(g,tp)
	local ct=0
	for tc in aux.Next(g) do
		local maxc=tc:GetCounter(COUNTER_CURSEFLAME)
		for i=maxc,1,-1 do
			if tc:IsCanRemoveCounter(tp,COUNTER_CURSEFLAME,i,REASON_EFFECT) then
				ct=ct+i
				if ct>=3 then
					return true
				end
			end
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(Card.HasCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,COUNTER_CURSEFLAME)
	if chk==0 then return c:IsCanAddCounter(COUNTER_CURSEFLAME,3) and g:CheckSubGroup(s.gcheck,1,#g,tp) end
	local ct=g:GetSum(Card.GetCounter,COUNTER_CURSEFLAME)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,tp,COUNTER_CURSEFLAME)
	local dg=Duel.Group(s.excfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsCanAddCounter(COUNTER_CURSEFLAME,1) then return end
	local g=Duel.Group(Card.HasCounter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,COUNTER_CURSEFLAME)
	if not g:CheckSubGroup(s.gcheck,1,#g,tp) then return end
	local ct=0
	for tc in aux.Next(g) do
		local maxc=tc:GetCounter(COUNTER_CURSEFLAME)
		for i=maxc,1,-1 do
			if c:IsCanAddCounter(COUNTER_CURSEFLAME,ct+i) and tc:IsCanRemoveCounter(tp,COUNTER_CURSEFLAME,i,REASON_EFFECT) and tc:RemoveCounter(tp,COUNTER_CURSEFLAME,i,REASON_EFFECT) then
				ct=ct+maxc-tc:GetCounter(COUNTER_CURSEFLAME)
				break
			end
		end
	end
	if ct==0 then return end
	if c:AddCounter(COUNTER_CURSEFLAME,ct) then
		local dg=Duel.Group(s.excfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,tp)
		if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 then
			local og=Duel.GetGroupOperatedByThisEffect(e)
			for tc in aux.Next(og) do
				local e2=Effect.CreateEffect(c)
				e2:SetDescription(STRING_CANNOT_TRIGGER)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
				e2:SetCode(EFFECT_CANNOT_TRIGGER)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
	end
end

--E2
function s.damcon(e,tp)
	return Duel.GetLP(1-tp)>300
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	local b1=ct>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	local b2=ct>3 and c:IsCanRemoveCounter(tp,COUNTER_CURSEFLAME,3,REASON_COST)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,2,b1,b2)
	if opt==0 then
		c:RemoveOverlayCard(tp,1,1,REASON_COST)
	elseif opt==1 then
		c:RemoveCounter(tp,COUNTER_CURSEFLAME,3,REASON_COST)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	if chk==0 then return e:IsCostChecked() or ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	if ct==0 then return end
	local p=Duel.GetTargetPlayer()
	Duel.RegisterFlagEffect(p,id,RESET_CHAIN,0,1)
	if Duel.Damage(p,ct*300,REASON_EFFECT)>0 and Duel.GetLP(p)<=0 then
		Duel.SetLP(p,300)
	end
	Duel.ResetFlagEffect(p,id)
end