--Olympus, Portale Nottesfumo dell'Ascensione
--Script by XGlitchy30
function c62613315.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SYNCHRO))
	e1:SetValue(500)
	c:RegisterEffect(e1)	
	--special summon (deck)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62613315,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,62613315)
	e2:SetLabel(100)
	e2:SetCondition(c62613315.spcon)
	e2:SetTarget(c62613315.sptg)
	e2:SetOperation(c62613315.spop)
	c:RegisterEffect(e2)
	--special summon (banished)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(62613315,1))
	e3:SetLabel(101)
	c:RegisterEffect(e3)
	--xyz with a synchro
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(62613315,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,60613315)
	e4:SetTarget(c62613315.xyztg)
	e4:SetOperation(c62613315.xyzop)
	c:RegisterEffect(e4)
	--replace field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(62613315,3))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,61613315)
	e5:SetCost(c62613315.actcost)
	e5:SetTarget(c62613315.acttg)
	e5:SetOperation(c62613315.actop)
	c:RegisterEffect(e5)
end
--filters
function c62613315.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER)
end
function c62613315.spfilter(c,e,tp)
	return c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_DECK) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function c62613315.synfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x6233)
		and Duel.IsExistingTarget(c62613315.xyzfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
function c62613315.xyzfilter(c,e,tp,mc)
	if c:GetOriginalCode()==6165656 and mc:GetCode()~=48995978 then return false end
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x6233) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c62613315.fieldfilter(c,tp)
	return c:IsCode(62613316) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
--special summon
function c62613315.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c62613315.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function c62613315.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=nil
	if e:GetLabel()==100 then
		loc=LOCATION_DECK
	elseif e:GetLabel()==101 then
		loc=LOCATION_REMOVED
	end
	if chk==0 then return loc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c62613315.spfilter,tp,loc,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function c62613315.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=nil
	if e:GetLabel()==100 then
		loc=LOCATION_DECK
	elseif e:GetLabel()==101 then
		loc=LOCATION_REMOVED
	end
	if not loc then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(c62613315.spfilter,tp,loc,0,nil,e,tp)
	if ft<=0 or g:GetCount()<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
--xyz with a synchro
function c62613315.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c62613315.synfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,c62613315.synfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if g1:GetCount()<=0 then return end
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,aux.NecroValleyFilter(c62613315.xyzfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabelObject())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
function c62613315.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=2 then return end
	local tc=e:GetLabelObject()
	if not g:IsContains(tc) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=-1 or not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	g:RemoveCard(tc)
	local sc=g:GetFirst()
	if sc and sc:IsLocation(LOCATION_GRAVE) then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			Duel.SendtoGrave(mg,REASON_RULE)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
--replace field
function c62613315.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c62613315.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c62613315.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function c62613315.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62613315,3))
	local tc=Duel.SelectMatchingCard(tp,c62613315.fieldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=tc:GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	end
end