--created & coded by Lyris
--フェイト・ヒーローブルーＬｉｇｈｔ－９
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,cid.mfilter1,cid.mfilter2,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.damcon)
	e1:SetTarget(cid.damtg)
	e1:SetOperation(cid.damop)
	c:RegisterEffect(e1)
end
function cid.mfilter1(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0xf7a) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.mfilter2(c,fc,sub,mg,sg)
	return c:IsAttackAbove(1900) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.filter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsSetCard(0xf7a) or not c:IsType(TYPE_SPELL) or not c:IsAbleToDeck() then return false end
	for _,ef in pairs(global_card_effect_table[c]) do
		local tg=ef:GetTarget()
		if ef:IsHasCategory(CATEGORY_FUSION_SUMMON) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) then return true end
	end
	return false
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc,e,tp,eg,ep,e,v,re,r,rp) end
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp),1,0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)==0 then return end
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	local t={}
	local ops={}
	for _,ef in pairs(global_card_effect_table[tc]) do
		local tg=ef:GetTarget()
		if ef:IsHasCategory(CATEGORY_FUSION_SUMMON) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) then
			table.insert(t,ef)
			if ef:IsHasType(EFFECT_TYPE_ACTIVATE) then table.insert(ops,1150)
			else table.insert(ops,ef:GetDescription()) end
		end
	end
	local te=t[Duel.SelectOption(tp,table.unpack(ops))+1]
	tc:CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function cid.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function cid.dfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:GetAttack()>0
end
function cid.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ((chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp))
		or (chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp))) and cid.dfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.dfilter,tp,LOCATION_MZONE,LOCATION_GRAVE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cid.dfilter,tp,LOCATION_MZONE,LOCATION_GRAVE,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
function cid.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
