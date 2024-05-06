--Higan Converguard
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	Converguard.EnableConvergence(c)
	--SS
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(ref.sscon)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	--Shuffle
	--[[local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER_E)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(ref.dktg)
	e1:SetOperation(ref.dkop)
	c:RegisterEffect(e1)]]
	--Cycle
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTarget(ref.drtg)
	e2:SetOperation(ref.drop)
	c:RegisterEffect(e2)
end

--SS
function ref.sscfilter(c) return Converguard.Is(c) end
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(ref.sscfilter,1,nil)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,c:GetLocation())
end
function ref.ssxfilter(c)
	return c:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED+LOCATION_GRAVE) and c:IsAbleToHand()
end
function ref.ssop(e,tp,eg) local c=e:GetHandler()
	local g=eg:Filter(ref.sscfilter,nil):Filter(ref.ssxfilter,nil)
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then Duel.SendtoHand(sg,nil,REASON_EFFECT) end
	end
end
--[[function ref.ssfilter(c,e,tp) return Converguard.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and c:IsAbleToRemove()
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,c:GetLocation())
end
function ref.rmfilter(c,rc)
	return (rc:IsAttribute(ATTRIBUTE_WATER) and c:IsAttribute(ATTRIBUTE_FIRE))
		or (rc:IsAttribute(ATTRIBUTE_FIRE) and c:IsAttribute(ATTRIBUTE_WATER))
		or (rc:IsAttribute(ATTRIBUTE_DARK) and c:IsAttribute(ATTRIBUTE_LIGHT))
		or (rc:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttribute(ATTRIBUTE_DARK))
		or (rc:IsAttribute(ATTRIBUTE_EARTH) and c:IsAttribute(ATTRIBUTE_WIND))
		or (rc:IsAttribute(ATTRIBUTE_WIND) and c:IsAttribute(ATTRIBUTE_EARTH))
end
function ref.ssop(e,tp) local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) then
			local rg=Group.FromCards(c)
			local rg2=Duel.SelectMatchingCard(tp,ref.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil,g:GetFirst())
			if #rg2>0 then rg:Merge(rg2) end
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end]]

function ref.dkfilter(c,e,tp)
	if not (c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)) then return false end
	return c:IsType(TYPE_MONSTER) or c:IsControler(1-tp)
end
function ref.sdkfilter(c,e) return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e) end
function ref.dkgfilter(g,tp)
	return g:FilterCount(Card.IsControler,nil,tp)==g:FilterCount(Card.IsControler,nil,1-tp)
end
function ref.dktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(ref.sdkfilter,tp,LOCATION_GRAVE,0,1,nil,e)
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
	end
	e:SetLabel(0)
	local opg=Duel.GetMatchingGroup(ref.dkfilter,tp,0,LOCATION_GRAVE,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp,ref.dkfilter,tp,LOCATION_GRAVE,0,1,math.min(#opg,2),nil,e,tp)
	local g2=opg:Select(tp,1,#sg,nil,e,tp)
	sg:Merge(g2)
	--[[local g=Duel.GetMatchingGroup(ref.dkfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	local sg=Group.CreateGroup()
	local finish=false
	local max=4
	while #sg<=max and not finish do
		finish=ref.dkgfilter(sg,tp)
		if #sg<=max then
			local cg=g
			cg:Sub(sg)
			if #cg==0 then break end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local tc=cg:SelectUnselect(sg,tp,finish,false,2,max)
			if not tc then break end
			if not sg:IsContains(tc) then
				sg:AddCard(tc)
				if #sg>=max then finish=true end
			else
				sg:RemoveCard(tc)
			end
		end
	end]]
	Duel.SetTargetCard(sg)
	local bg=Group.CreateGroup()
	if sg:IsExists(Card.IsAttribute,1,nil,e:GetHandler():GetAttribute()) then
		e:SetLabel(1)
		bg=sg:Filter(Card.IsControler,nil,1-tp)
		sg:Sub(bg)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	if #bg>0 then Duel.SetOperationInfo(0,CATEGORY_REMOVE,bg,#bg,0,0) end
end
function ref.dkop(e,tp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local bg=Group.CreateGroup()
	if e:GetLabel()==1 then
		bg=g:Filter(Card.IsControler,nil,1-tp)
		g:Sub(bg)
	end
	if #g>0 then Duel.SendtoDeck(g,nil,REASON_EFFECT) end
	if #bg>0 then Duel.Remove(bg,POS_FACEDOWN,REASON_EFFECT) end
end

--Cycle
function ref.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetParam(1)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
function ref.drop(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then Duel.DiscardHand(p,aux.TRUE,1,1,REASON_EFFECT,nil) end
end
