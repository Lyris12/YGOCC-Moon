--created by Zarc, coded by Lyris
--Elflair - Grover, Overgrown Vine King
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x355),3)
	c:SetUniqueOnField(1,0,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_ATKCHANGE)
	e2:SetTarget(s.rttg)
	e2:SetOperation(s.rtop)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp,chk)
	return c:IsFaceup() and c:IsSetCard(0x355) and c:IsAttackAbove(2000) and c:IsAbleToRemove() and (chk
		or not c:IsImmuneToEffect(e)
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp,c))
end
function s.sfilter(c,e,tp,tc)
	return c:IsSetCard(0x355) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsLocation(LOCATION_EXTRA)
		and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0 or Duel.GetMZoneCount(tp,tc)>0)
end
function s.rmtg(e,tp,_,_,_,_,_,_,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.rmop(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	if #g<1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.Remove(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,true),POS_FACEUP,REASON_EFFECT)
		return
	end
	Duel.HintSelection(g)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function s.afilter(c)
	return c:IsFaceup() and c:IsAttackAbove(1)
end
function s.rfilter(c)
	return c:IsSetCard(0x355) and c:IsType(TYPE_LINK+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsAbleToExtra()
end
function s.rttg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.afilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(s.afilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.afilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.rtop(e,tp)
	local g=Duel.GetMatchingGroup(s.rfilter,tp,LOCATION_GRAVE,0,nil)
	local ops={[TYPE_FUSION]={[2]=1056},[TYPE_SYNCHRO]={[2]=1063},[TYPE_XYZ]={[2]=1073},[TYPE_LINK]={[2]=1076}}
	for t in pairs(ops) do
		ops[t][1]=g:IsExists(Card.IsType,1,nil,t)
		ops[t][3]=t
	end
	local typ=aux.SelectFromOptions(tp,table.unpack(ops))
	if not typ then return end
	local tg=g:Filter(Card.IsType,nil,typ)
	local ct=Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	local tc=Duel.GetFirstTarget()
	if #tg~=ct or tg:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_EXTRA) or not tc:IsRelateToEffect(e)
		or tc:IsFacedown() or tc:IsControler(tp) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(0)
	tc:RegisterEffect(e1)
end
