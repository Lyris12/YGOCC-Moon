--Andromedas Markshall
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--pandemonium
	aux.AddOrigPandemoniumType(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:GLString(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(aux.PandActCon)
	e1:SetTarget(cid.sptg)
	e1:SetValue(cid.spop)
	c:RegisterEffect(e1)
	aux.EnablePandemoniumAttribute(c,e1)
	--special summon proc
	local e2=Effect.CreateEffect(c)
	e2:GLString(1)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(cid.spcon)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	--bounce and search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(cid.thcon)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
function cid.counterfilter(c)
	return c:IsSetCard(0x7a4) or c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)
end
--SPSUMMON
function cid.spfilter(c,e,tp,atk)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM) and c:GetAttack()<atk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0) 
end
function cid.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PANDEMONIUM) and Duel.IsExistingMatchingCard(cid.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttack())
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsType(TYPE_PENDULUM) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not e:GetHandler():IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
	local atk=tc:GetAttack()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp,atk):GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--SPECIAL SUMMON PROC
function cid.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM)
end
function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(cid.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c)
	return not cid.counterfilter(c)
end

--POP AND PLACE
function cid.dryfilter(c,e,tp)
	return (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)
		and Duel.IsExistingMatchingCard(cid.pfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetOriginalAttribute(),c:GetType())
end
function cid.spfilter(c,e,tp,attr,typ)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsAttribute(attr) and not c:IsForbidden()
		and (c:IsType(TYPE_PENDULUM) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		or (c:IsType(TYPE_PANDEMONIUM) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandActCon(nil,c)(e,tp,eg,ep,ev,re,r,rp)))
		and bit.band(typ,c:GetType()&(TYPE_PENDULUM+TYPE_PANDEMONIUM))==0
end
function cid.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function cid.ssop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	if g1:GetCount()>0 then
		Duel.HintSelection(g1)
		if Duel.Destroy(g1,REASON_EFFECT)~=0 then
			local attr,typ=g1:GetFirst():GetOriginalAttribute(),g1:GetFirst():GetType()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
			local g2=Duel.SelectMatchingCard(tp,cid.pfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,attr,typ):GetFirst()
			if not g2 then return end
			if g2:IsType(TYPE_PENDULUM) then
				Duel.MoveToField(g2,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			else
				aux.PandAct(g2)(e,tp,eg,ep,ev,re,r,rp)
			end		
		end
	end
end

--BOUNCE AND SEARCH
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re and (re:GetHandler():IsSetCard(0x7a4) or re:IsActiveType(TYPE_SPELL+TYPE_TRAP))
end
function cid.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7a4) and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and c:IsAbleToHand()
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function cid.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and c:IsAbleToHand()
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_HAND) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end