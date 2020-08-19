--created & coded by Lyris, art from "Guardian Elma" & at https://us.123rf.com/450wm/iimages/iimages1603/iimages160300284/53485338-stock-vector-forest-scene-with-trail-in-the-woods-illustration.jpg?ver=6
--インライトメント・エルマ武器庫
local cid,id=GetID()
function cid.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCondition(cid.descon)
	e2:SetTarget(cid.destg)
	e2:SetOperation(cid.desop)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1152)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function cid.filter(c,e,tp)
	return c:IsCode(CARD_INLIGHTENED_PSYCHIC_HELMET) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(cid.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
function cid.descon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if d and d:IsControler(tp) then a,d=d,a end
	return a:IsSetCard(0xda6) and a~=e:GetHandler()
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local dir=Duel.GetAttackTarget()==nil
	if chkc then
		if dir then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		else return chkc==Duel.GetAttacker():GetBattleTarget() end
	end
	if chk==0 then return true end
	local g=Group.FromCards(Duel.GetAttacker():GetBattleTarget())
	if dir then
		g=Duel.SelectMatchingCard(tp,Card.IsCanBeEffectTarget,tp,0,LOCATION_MZONE,1,1,nil,e)
	end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
