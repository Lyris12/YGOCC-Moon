--created by Walrus, coded by XGlitchy30
--Voidictator Rune - Raging Flames
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:HOPT(true)
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetCurrentChain()>=3 and Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_VOIDICTATOR_DEMON),tp,LOCATION_MZONE,0,1,nil)) then return false end
	for i=1,ev do
		local te,p=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if te:IsActivated() and p==1-tp and Duel.IsChainNegatable(i) then
			return true
		end
	end
	return false
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.chfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_VOIDICTATOR_DEMON_THE_UNENDING_FLAME)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg,dp=Group.CreateGroup(),1-tp
	local lg,lp=Group.CreateGroup(),1-tp
	local locs=0
	for i=1,ev do
		local te,p,loc,cp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
		if te:IsActivated() and p==1-tp then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			locs=locs|loc
			if cp==tp then
				dp=PLAYER_ALL
			end
			if tc:IsRelateToChain(i) then
				dg:AddCard(tc)
				if loc&LOCATION_GRAVE==LOCATION_GRAVE then
					lg:AddCard(tc)
					if cp==tp then
						lp=PLAYER_ALL
					end
				end
			end
		end
	end
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,#ng,0,0)
	local xyzg=Duel.Group(s.chfilter,tp,LOCATION_ONFIELD,0,nil)
	if #xyzg>0 then
		Duel.SetChainLimit(s.chlimit)
		if #lg>0 then
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,lg,#lg,lp,LOCATION_GRAVE)
		end
	else
		if #dg==0 then
			Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,dp,locs)
		else
			Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,dg,#dg,dp,locs)
		end
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.xyzcheck(c)
	return c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,p=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		local tc=te:GetHandler()
		if te:IsActivated() and p==1-tp and Duel.NegateActivation(i) and tc:IsRelateToChain() and tc:IsRelateToChain(i) then
			dg:AddCard(tc)
		end
	end
	if #dg>0 then
		local xyzg=Duel.Group(s.chfilter,tp,LOCATION_ONFIELD,0,nil)
		if #xyzg>0 then
			local ag=dg:Filter(Card.IsCanOverlay,nil,tp)
			local xyz=xyzg:FilterSelect(tp,s.xyzcheck,1,1,nil):GetFirst()
			if xyz and #ag>0 then
				for tc in aux.Next(ag) do
					tc:CancelToGrave()
				end
				Duel.Attach(ag,xyz)
			end
		else
			local tg=dg:Filter(Card.IsAbleToGrave,nil)
			if #tg>0 then
				Duel.SendtoGrave(tg,REASON_EFFECT)
			end
		end
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.cfilter(c)
	return (c:IsLocation(LOCATION_MZONE) or c:IsMonster()) and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,nil)
	Duel.Release(g,REASON_COST)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end
