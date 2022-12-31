--Emerald Summoner Mage
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249001037.initial_effect(c)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30914564,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,2490010371)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c249001037.target)
	e1:SetOperation(c249001037.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,2490010372)
	e4:SetTarget(c249001037.target2)
	e4:SetOperation(c249001037.operation2)
	c:RegisterEffect(e4)
end
function c249001037.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetChainLimit(aux.FALSE)
end
function c249001037.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c249001037.rmfilter(c)
	local g=Duel.GetMatchingGroup(c249001037.releasefilter,tp,LOCATION_MZONE+LOCATION_HAND,0,c)
	return c:IsType(TYPE_NORMAL+TYPE_DUAL) and not c:IsType(TYPE_PENDULUM) and c:IsAbleToRemove() and g:CheckWithSumGreater(Card.GetLevel,6,1,99,c)
end
function c249001037.releasefilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and not c:IsHasEffect(EFFECT_UNRELEASABLE_NONSUM)
end
function c249001037.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001037.rmfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	Duel.SetChainLimit(aux.FALSE)
end
function c249001037.operation2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c249001037.rmfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) then return end
	local c=e:GetHandler()
	local sc
	local g=Duel.SelectMatchingCard(tp,c249001037.rmfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local rc=g:GetFirst()
	Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	local lvrk
	local lvrk15
	repeat
		local ac=Duel.AnnounceCard(tp,TYPE_SYNCHRO+TYPE_XYZ,OPCODE_ISTYPE)
		sc=Duel.CreateToken(tp,ac)
		if sc:IsLevelAbove(1) then lvrk=sc:GetLevel() else lvrk=sc:GetRank() end
		lvrk15=math.ceil(lvrk *1.5)
		g=Duel.GetMatchingGroup(c249001037.releasefilter,tp,LOCATION_MZONE+LOCATION_HAND,0,rc)
	until (lvrk >=4 and g:CheckWithSumGreater(Card.GetLevel,lvrk15,1,99,nil) and ((sc:IsType(TYPE_SYNCHRO) and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)) or (sc:IsType(TYPE_XYZ) and sc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)))
		 and not banned_list_table[ac])
	local sg=g:SelectWithSumGreater(tp,Card.GetLevel,lvrk15,1,99,nil)
	Duel.Release(sg,REASON_EFFECT)
	Duel.SendtoDeck(sc,nil,0,REASON_RULE)
	local sumtype=SUMMON_TYPE_SYNCHRO
	if sc:IsType(TYPE_XYZ) then
		sumtype=SUMMON_TYPE_XYZ
		g=Duel.GetMatchingGroup(aux.NecroValleyFilter(aux.TRUE),tp,LOCATION_GRAVE,0,nil)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local mg=g:Select(tp,1,2,nil)
			Duel.Overlay(sc,mg)
		end
		Duel.SpecialSummon(sc,sumtype,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end