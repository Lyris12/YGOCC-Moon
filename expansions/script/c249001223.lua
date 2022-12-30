--Galactic Form Magician
function c249001223.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2)
	aux.EnablePendulumAttribute(c,false)
	c:EnableReviveLimit()
	--xyz summon / excavate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,2490012231)
	e1:SetCost(c249001223.cost)
	e1:SetTarget(c249001223.target)
	e1:SetOperation(c249001223.operation)
	c:RegisterEffect(e1)
	--attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(93)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c249001223.condition)
	e2:SetTarget(c249001223.target2)
	e2:SetOperation(c249001223.operation2)
	c:RegisterEffect(e2)
	--to pzone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74892653,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCondition(c249001223.pcon)
	e3:SetTarget(c249001223.ptg)
	e3:SetOperation(c249001223.pop)
	c:RegisterEffect(e3)
	--xyz summon (pzone)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,2490012232)
	e4:SetTarget(c249001223.sptg)
	e4:SetOperation(c249001223.spop)
	c:RegisterEffect(e4)
	--destroy and banish
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c249001223.descon)
	e5:SetTarget(c249001223.destg)
	e5:SetOperation(c249001223.desop)
	c:RegisterEffect(e5)
end
c249001223.pendulum_level=4
function c249001223.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsSetCard(0x1B7) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function c249001223.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and Duel.IsExistingMatchingCard(c249001223.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE+LOCATION_EXTRA,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001223.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001223.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c249001223.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	g=g:Filter(Card.IsType,nil,TYPE_MONSTER)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_XYZ_MATERIAL)
		e1:SetValue(aux.TRUE)
		e1:SetReset(RESET_EVENT)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_END)
		e2:SetRange(0xFF)
		e2:SetOperation(c249001223.resetop)
		e2:SetLabelObject(e1)
		e2:SetReset(RESET_EVENT)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	local sg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,1165) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
	Duel.ShuffleDeck(tp)
end
function c249001223.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end
function c249001223.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function c249001223.filter2(c)
	return c:IsSetCard(0x1B7) and (c:IsFaceup() or not c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_MONSTER)
end
function c249001223.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c249001223.filter2),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
end
function c249001223.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c249001223.filter2),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
    if g:GetCount()>0 then
    	Duel.Overlay(c,g)
    end
end
function c249001223.pcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c249001223.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
		or Duel.IsExistingMatchingCard(c249001223.filter3,tp,LOCATION_ONFIELD,0,1,nil)) end
end
function c249001223.filter3(c)
	return c:IsSetCard(0x1B7) and c:IsFaceup()
end
function c249001223.pop(e,tp,eg,ep,ev,re,r,rp)
	if (not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and not Duel.IsExistingMatchingCard(c249001223.filter3,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	local g=Duel.SelectMatchingCard(tp,c249001223.filter3,tp,LOCATION_ONFIELD,0,1,1,nil)
    if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c249001223.filter1(c,e,tp)
	return c:GetRank() < 5 and c:GetRank() > 0 and c:IsType(TYPE_XYZ)
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(c249001223.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()*2,c:GetAttribute())
end
function c249001223.filter2(c,e,tp,mc,rk,att)
	return c:IsRank(rk) and c:IsAttribute(att) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function c249001223.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c249001223.filter1(chkc,e,tp) end
	if chk==0 then return e:GetHandler():IsDestructable() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and Duel.IsExistingTarget(c249001223.filter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local g=Duel.SelectTarget(tp,c249001223.filter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,nil,tp,LOCATION_EXTRA)
end
function c249001223.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.Destroy(c,REASON_EFFECT)==0 or Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)==0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c249001223.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()*2,tc:GetAttribute())
	local sc=g:GetFirst()
	if sc then
		Duel.BreakEffect()
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function c249001223.desfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsControler(tp) and not c:IsCode(249001223)
end
function c249001223.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c249001223.desfilter,1,nil,tp)
end
function c249001223.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function c249001223.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
     if tc:IsRelateToEffect(e) then
         Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
     end
end