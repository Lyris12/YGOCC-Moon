--Call of the Signer Dragon
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
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,cid.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_FLIPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return not c:IsCode(101600116)
end
function cid.cfilter1(c,lv,exclv)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) and not c:IsPublic() and not c:IsFaceup() and c:IsLevel(lv) and (not exclv or not c:IsLevel(exclv))
end
function cid.thfilter(c)
	return c:IsCode(101600116) and c:IsAbleToHand()
end
function cid.customcheck(g)
	return aux.dncheck(g) and g:IsExists(cid.cfilter1,3,nil,7,nil) and g:IsExists(cid.cfilter1,3,nil,8,7)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(cid.cfilter1,tp,LOCATION_EXTRA,0,nil,7,nil)
	local g2=Duel.GetMatchingGroup(cid.cfilter1,tp,LOCATION_EXTRA,0,g1,8,7)
	g1:Merge(g2)
	if chk==0 then return g1:CheckSubGroup(cid.customcheck,6,6) and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_FLIPSUMMON)==0
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.sumlimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=g1:SelectSubGroup(tp,cid.customcheck,false,6,6)
	Duel.ConfirmCards(1-tp,cg)
end
function cid.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not cid.counterfilter(c)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTarget(function(e,c) return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) end)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.GetFirstMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,nil)
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
end
