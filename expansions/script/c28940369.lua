--Converguard Ascendence
local ref,id=GetID()
Duel.LoadScript("Commons_Converguard.lua")
function ref.initial_effect(c)
	--Hand Act
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(ref.handcon)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.drtg)
	e1:SetOperation(ref.drop)
	c:RegisterEffect(e1)
	--Revive
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(ref.optg)
	e2:SetOperation(ref.opop)
	c:RegisterEffect(e2)
end
function ref.handcon(e)
	return Duel.IsExistingMatchingCard(aux.FilterEqualFunction(Card.GetSummonLocation,LOCATION_EXTRA),e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end

--Activate
function ref.destg(c) return Converguard.Is(c) and bit.band(c:GetOriginalType(),TYPE_MONSTER)==TYPE_MONSTER end
function ref.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and ref.destg(chkc) end
	if chk==0 then return Duel.IsExistingTarget(ref.destg,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,ref.destg,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,nil,tp,2)
end
function ref.drop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)~=0 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

--Revive
function ref.opfilter(c,e,tp)
	if not (c:IsFaceup() and (Converguard.Is(c) or c:IsControler(1-tp))) then return false end
	if c:IsType(TYPE_PENDULUM) then return c:IsControler(tp) or c:IsControlerCanBeChanged(true) end
	if c:IsType(TYPE_TIMELEAP) then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	if c:IsType(TYPE_SPELL|TYPE_TRAP) then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable(true) end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function ref.optg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and ref.opfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(ref.opfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectTarget(tp,ref.opfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,c,e,tp):GetFirst()
	if tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_PENDULUM) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,tc:GetLocation())
	end
end
function ref.opop(e,tp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return false end
	if tc:IsType(TYPE_PENDULUM) then Duel.SendtoExtraP(tc,tp,REASON_EFFECT) return false end
	if tc:IsType(TYPE_MONSTER) then
		local pos=POS_FACEDOWN_DEFENSE
		if tc:IsType(TYPE_TIMELEAP) then pos=POS_FACEUP end
		Duel.SpecialSummon(tc,0,tp,tp,false,false,pos)
		return false
	end
	Duel.SSet(tp,tc,tp)
end

function ref.grfilter(c,e) return c:IsType(TYPE_PENDULUM) and c:IsCanBeEffectTarget(e) end
function ref.ssfilter(c,e,tp)
	return c:IsType(TYPE_TIMELEAP) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.grfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e)
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,ref.grfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,#g2,tp,LOCATION_GRAVE)
	g1:Merge(g2)
	Duel.SetTargetCard(g1)
end
function ref.ssop(e,tp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local x,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON):Filter(Card.IsRelateToEffect,nil,e)
	g:Sub(g2)
	if #g>0 and Duel.SendtoGrave(g,REASON_RETURN|REASON_EFFECT)~=0 and #g2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
	end
end
