--GearRATtachment
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTarget(aux.FilterBoolFunction(Card.IsCode,55935416))
	e2:SetValue(cid.atkval)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2x)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCost(cid.drawcost)
	e3:SetTarget(cid.drawtg)
	e3:SetOperation(cid.drawop)
	c:RegisterEffect(e3)
	--leave replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(cid.reptg)
	e4:SetValue(cid.repval)
	e4:SetOperation(cid.repop)
	c:RegisterEffect(e4)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsRank(1)
end

--ATK
function cid.atkval(e,c)
	return c:GetOverlayCount()*1000
end

--DRAW
function cid.filter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and (not c:IsOnField() or c:IsFaceup())
		and Duel.IsExistingTarget(cid.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,c,c:GetLevel())
		and Duel.IsPlayerCanDraw(tp,c:GetLevel()-1) and c:IsCanOverlay()
end
function cid.filter2(c,lv)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and (not c:IsOnField() or c:IsFaceup()) and c:IsLevel(lv) and c:IsCanOverlay()
end
function cid.spfilter(c,e,tp)
	return c:IsCode(55935416) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function cid.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(1))
end
function cid.drawtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(cid.filter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.filter1),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.filter2),tp,LOCATION_MZONE+LOCATION_GRAVE,0,2,2,tc1,tc1:GetLevel())
	g1:Merge(g2)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(tc1:GetLevel()-1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,tc1:GetLevel()-1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	local tg=g1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #tg>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tg,#tg,0,0)
	end
end
function cid.drawop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #g<=0 or g:GetClassCount(Card.GetLevel)>1 then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=g:GetFirst():GetLevel()-1
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	if ct~=0 then
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,ct-1,ct-1,nil)
		if #dg>0 then
			Duel.BreakEffect()
			if Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)~=0 then
				local og=Duel.GetOperatedGroup()
				if og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0 then
					Duel.ShuffleDeck(tp)
				end
				if og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<#og then return end
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCountFromEx(tp)<=0 then return end
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,cid.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
				local sc=sg:GetFirst()
				if sc then
					Duel.Overlay(sc,g)
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end

--LEAVE REPLACE
--filters
function cid.repfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and not c:IsReason(REASON_REPLACE) and c:IsControler(tp) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT+REASON_REPLACE)
		and bit.band(c:GetDestination(),LOCATION_MZONE)==0 and bit.band(c:GetDestination(),LOCATION_SZONE)==0
		and bit.band(c:GetDestination(),LOCATION_FZONE)==0 and bit.band(c:GetDestination(),LOCATION_PZONE)==0
end
---------
function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return r&REASON_EFFECT~=0 and re and rp~=tp and and eg:IsExists(cid.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(cid.rmfilter,tp,LOCATION_DECK,0,2,nil) 
	end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=eg:Filter(cid.repfilter,nil,tp)
		local ct=g:GetCount()
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			g=g:Select(tp,1,ct,nil)
		end
		Duel.SetTargetCard(g)
		return true
	end
	return false
end
function cid.repval(e,c)
	return cid.repfilter(c,e:GetHandlerPlayer())
end
function cid.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	while tc do
		tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		tc=g:GetNext()
	end
end