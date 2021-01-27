--Signer Dragon's Duality
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
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--ACTIVATE
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsChainDisablable(ev)
end
function cid.spcfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and c:IsAbleToExtra()
		and Duel.GetMZoneCount(tp,c)>1 and Duel.IsExistingMatchingCard(cid.mgfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c,c:GetLevel())
end
function cid.mgfilter(c,e,tp,cc,lv)
	local g=(cc~=nil) and Group.FromCards(c,cc) or c
	return lv>0 and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and ((not c:IsSetCard(0xcd01) and c:GetLevel()==lv) or (c:IsSetCard(0xcd01) and Duel.IsExistingMatchingCard(cid.mgfilter,tp,LOCATION_GRAVE,0,1,g,e,tp,cc,lv-c:GetLevel())))
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.IsExistingTarget(cid.spcfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cid.spcfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT) and tc:IsLocation(LOCATION_EXTRA) then
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
		local lv=tc:GetLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.mgfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,nil,lv)
		if not g1:GetFirst() then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.mgfilter),tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp,nil,lv-g1:GetFirst():GetLevel())
		if not g2:GetFirst() then return end
		g1:Merge(g2)
		if #g1==2 then
			local sc=g1:GetFirst()
			while sc do
				if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetDescription(aux.Stringid(id,1))
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
					e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
					e1:SetValue(aux.indoval)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					sc:RegisterEffect(e1)
					local e2=Effect.CreateEffect(e:GetHandler())
					e2:SetDescription(aux.Stringid(id,2))
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
					e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_IGNORE_IMMUNE)
					e2:SetValue(aux.tgoval)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					sc:RegisterEffect(e2)
					sc=g1:GetNext()
				end
			end
			Duel.SpecialSummonComplete()
		end
	end
end