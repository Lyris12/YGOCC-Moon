--Ancient Divexplorer, Megalo
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,ref=getID()
function ref.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,3,ref.matgfilter)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetLabel(0)
	e1:SetCost(ref.rmcost)
	e1:SetTarget(ref.rmtg)
	e1:SetOperation(ref.rmop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Revive
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DRAW_PHASE+TIMING_END_PHASE)
	e2:SetTarget(ref.sstg)
	e2:SetOperation(ref.ssop)
	e2:SetCountLimit(1,id+1000)
	c:RegisterEffect(e2)

end
function ref.matgfilter(g,lc,tp)
	return g:GetClassCount(Card.GetLinkRace,tp)==1 and g:GetClassCount(Card.GetLinkAttribute,lc)==#g
end

function ref.rmcfilter(c)
	return c:IsAbleToRemoveAsCost()
end
function ref.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		--and Duel.IsExistingMatchingCard(ref.rmcfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	--e:SetLabel(c:GetAttack())
	--Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	--local g=Duel.SelectMatchingCard(tp,ref.rmcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	--g:AddCard(c)
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	--local c=e:GetHandler()
	if chkc then return ref.rmcfilter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) end
	if chk==0 then return Duel.IsExistingTarget(ref.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	--if e:GetLabel()==0 then e:SetLabel(e:GetHandler():GetAttack()) end
	local val=(e:GetHandler():GetPreviousAttackOnField())/2
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,ref.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetTargetParam(val)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,nil,tp,val)
end
function ref.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local val=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		Duel.Recover(p,val,REASON_EFFECT)
		Duel.GainRP(p,val,REASON_EFFECT)
	end
	e:SetLabel(0)
end

function ref.get_zone(c,lc,tp)
	local seq=c:GetSequence()
	local zone=0
	if c:GetControler()==lc:GetControler() then
		if seq<4 and lc:IsLinkMarker(LINK_MARKER_LEFT) then zone=bit.replace(zone,0x1,seq+1) end
		if seq>0 and seq<5 and lc:IsLinkMarker(LINK_MARKER_RIGHT) then zone=bit.replace(zone,0x1,seq-1) end
	end
	local column=c:GetColumnZone(LOCATION_MZONE)
	zone=bit.bor(zone,column)
	return zone
end
function ref.zoneloop(c,lc,e,tp)
	local zone=e:GetLabel()
	local val=ref.get_zone(c,lc,tp)
	zone=bit.bor(zone,val)
	e:SetLabel(zone)
end
function ref.sstfilter(c)
	return bit.band(c:GetSummonLocation(),LOCATION_EXTRA)==LOCATION_EXTRA
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(ref.sstfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if 0>=#g then return false end
	e:SetLabel(0)
	g:ForEach(ref.zoneloop,c,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,e:GetLabel())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(ref.sstfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE) and c:IsRelateToEffect(e) then
		e:SetLabel(0)
		g:ForEach(ref.zoneloop,c,e,tp)
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,e:GetLabel())>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,1))
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			c:RegisterEffect(e2)
		end
	end
end
