--created by ZEN, coded by TaxingCorn117 & Lyris
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddLinkProcedure(c,nil,2,99,cid.lcheck)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_DAMAGE)
	e6:SetCategory(CATEGORY_RECOVER)
	e6:SetCountLimit(1,id+1000)
	e6:SetCondition(cid.rccon)
	e6:SetOperation(cid.rcop)
	c:RegisterEffect(e6)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK+CATEGORY_RECOVER)
	e1:SetCountLimit(1,id+2000)
	e3:SetCondition(aux.exccon)
	e3:SetTarget(cid.tdtg)
	e3:SetOperation(cid.tdop)
	c:RegisterEffect(e3)
end
function cid.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x52f)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,100)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_GRAVE)
end
function cid.checkzone(tp)
	local zone=0
	local g=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		zone=bit.bor(zone,tc:GetLinkedZone(tp))
	end
	return bit.band(zone,0x1f)
end
function cid.spfilter(c,e,tp,lv,zone)
	return c:IsSetCard(0x52f) and c:IsLevel(lv) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.TossDice(tp,1)
	if Duel.Damage(tp,dc*100,REASON_EFFECT)==0 or Duel.GetLP(tp)<=0 then return end
	local zone=cid.checkzone(tp)
	local g=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp,dc,zone)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function cid.rccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetControler()==ep and ev>=500
end
function cid.rcop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if Duel.IsChainDisablable(0) and #hg>0
		and Duel.SelectYesNo(1-tp,aux.Stringid(math.floor(id/100),2)) then
		Duel.DiscardHand(1-tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		Duel.NegateEffect(0)
		return
	end
	Duel.Recover(tp,Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)*200,REASON_EFFECT)
end
function cid.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1500)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,3,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
function cid.tdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(tp,1500,REASON_EFFECT)==0 or Duel.GetLP(tp)<=0 then return end
	local c=e:GetHandler()
	local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,2,2,nil)
	if not c:IsRelateToEffect(e) or not c:IsAbleToDeck() or #dg<2 then return end
	Duel.HintSelection(dg)
	local g=dg+c
	Duel.BreakEffect()
	if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)>0 and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK) then
		Duel.BreakEffect()
		Duel.Recover(tp,2000,REASON_EFFECT)
	end
end
