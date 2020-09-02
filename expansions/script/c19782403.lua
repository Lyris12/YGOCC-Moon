--created by ZEN, coded by ZEN & Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.sctg)
	e1:SetOperation(cid.scop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	e2:SetCost(cid.spcost)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1+id+200)
	e3:SetCondition(cid.plcon)
	e3:SetTarget(cid.pltg)
	e3:SetOperation(cid.plop)
	c:RegisterEffect(e3)
end
function cid.scfilter(c,tp)
	return c:IsSetCard(0xd7c) and (c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and not c:IsForbidden())
end
function cid.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.scfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function cid.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,cid.scfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	local ops,opct={},0
	if tc:IsAbleToHand() then table.insert(ops,1190) else opct=1 end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then table.insert(ops,aux.Stringid(id,1)) end
	local opt=Duel.SelectOption(tp,table.unpack(ops))+opct
	
	local c=e:GetHandler()
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1b:SetTargetRange(1,0)
	e1b:SetTarget(cid.splimit)
	e1b:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1b,tp)
	local e2=e1b:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	if opt==0 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetReset(RESET_EVENT+0x1fc0000)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+id+5,e,r,tp,tp,0)
	end
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cid.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cid.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cid.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cid.costfilter(c)
	return c:IsSetCard(0xd7c) and c:IsLocation(LOCATION_SZONE) and c:IsAbleToGraveAsCost()
end
function cid.spfilter(c,e,tp)
	return c:IsSetCard(0xd7c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_SZONE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_SZONE,0,2,2,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function cid.splimit(e,c)
	return not c:IsSetCard(0xd7c)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
function cid.plcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsSetCard(0xd7c)
end
function cid.plfilter(c,e,tp)
	return c:IsSetCard(0xd7c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function cid.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and cid.plfilter(chkc,e,tp) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,Duel.SelectTarget(tp,cid.plfilter,tp,LOCATION_GRAVE,0,1,2,e:GetHandler(),e,tp),2,0,0)
end
function cid.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<2 then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	for c in aux.Next(g) do
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetReset(RESET_EVENT+0x1fc0000)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
	Duel.RaiseEvent(g,EVENT_CUSTOM+id+5,e,r,tp,tp,0)
end
