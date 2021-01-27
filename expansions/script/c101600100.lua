--Signer Dragon's Road
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
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetLabel(0)
	e1:SetCondition(cid.condition)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cid.handcon)
	c:RegisterEffect(e2)
end
--ACTIVATE
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainDisablable(ev)
end
function cid.spcfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsAbleToExtraAsCost()
		and Duel.GetMZoneCount(tp,c)>1 and Duel.IsExistingMatchingCard(cid.mgfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,TYPE_TUNER,c,c:GetOriginalLevel())
end
function cid.mgfilter(c,e,tp,typ,cc,lv)
	local g=(cc~=nil) and Group.FromCards(c,cc) or c
	return lv>0 and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and ((not typ and not c:IsType(TYPE_TUNER) and c:GetLevel()==lv) or (typ and c:IsType(typ) and Duel.IsExistingMatchingCard(cid.mgfilter,tp,LOCATION_GRAVE,0,1,g,e,tp,nil,cc,lv-c:GetLevel())))
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.IsExistingMatchingCard(cid.spcfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.spcfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local lv=tc:GetOriginalLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.mgfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,TYPE_TUNER,nil,lv)
	if not g1:GetFirst() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.mgfilter),tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp,nil,nil,lv-g1:GetFirst():GetLevel())
	if not g2:GetFirst() then return end
	g1:Merge(g2)
	if #g1==2 then
		local ct=0
		local sc=g1:GetFirst()
		while sc do
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
				sc=g1:GetNext()
				ct=ct+1
			end
		end
		Duel.SpecialSummonComplete()
		if ct==2 and not re:GetHandler():IsDisabled() and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end

--ACT IN HAND
function cid.filter(c)
	return c:IsFacedown() or not (c:IsSetCard(0xcd01) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON))
end
function cid.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 and not Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,0,1,nil)
end
