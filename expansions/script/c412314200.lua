--created by Jake, coded by Lyris, art from Cardfight!! Vanguard's "Dragonic Overlord" & "Perdition Emperor Dragon, Dragonic Overlord the Great"
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cid.spcon)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(cid.tgcost)
	e3:SetOperation(cid.tgop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCost(cid.spcost)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spact)
	c:RegisterEffect(e2)
	if not cid.global_check then
		cid.global_check=true
		cid[0]=0
		cid[1]=0
	end
end
function cid.cfilter(c)
	return c:IsSetCard(0x613) and c:IsType(TYPE_MONSTER)
end
function cid.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_HAND,0,1,c)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function cid.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,2,e:GetHandler())
	e:SetLabel(#g)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function cid.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>0 and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ct-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function cid.filterchkc(sg,tp,e,g)
	local g1=sg:Filter(Card.IsDiscardable,nil)
	local g2=g:Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)-sg
	return #g1==#sg and g2:CheckSubGroup(aux.TRUE,#sg,#sg)
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(9)
	return true
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND,0,nil,0x613)
	if chk==0 then
		cid[tp]=0
		if e:GetLabel()~=9 then return false end
		e:SetLabel(0)
		return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and g:CheckSubGroup(cid.filterchkc,1,2,tp,e,g) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sg=g:SelectSubGroup(p,cid.filterchkc,false,1,2,tp,e,g)
	cid[tp]=#sg
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end
function cid.spact(e,tp,eg,ep,ev,re,r,rp)
	if cid[tp]>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<cid[tp] then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND,0,nil,0x613):FilterSelect(tp,Card.IsCanBeSpecialSummoned,cid[tp],cid[tp],nil,e,0,tp,false,false)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
