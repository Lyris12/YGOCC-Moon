--created & coded by Lyris
--フェイト・ヒーロープロヒビトガル
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return r==REASON_FUSION end)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cpfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsSetCard(0xa5f) or not c:IsType(TYPE_MONSTER) or not c:IsAbleToDeck()
		or c:IsCode(id) then return false end
	for _,ef in pairs(global_card_effect_table[c]) do
		local con=ef:GetCondition()
		local tg=ef:GetTarget()
		if ef:GetCode()==EVENT_BE_MATERIAL and (not con or con(e,tp,eg,ep,ev,re,REASON_FUSION,rp)) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) then return true end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	Duel.HintSelection(g)
	if #g==0 or Duel.SendtoDeck(g,nil,2,REASON_EFFECT)==0 then return end
	local tc=g:GetFirst()
	Duel.ShuffleDeck(tp)
	Duel.BreakEffect()
	local t={}
	local ops={}
	for _,ef in pairs(global_card_effect_table[tc]) do
		local tg=ef:GetTarget()
		if ef:IsHasCategory(CATEGORY_FUSION_SUMMON) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) then
			table.insert(t,ef)
			table.insert(ops,ef:GetDescription())
		end
	end
	local te=t[Duel.SelectOption(tp,table.unpack(ops))]
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.val)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.val(e,re,dam,r,rp,rc)
	return dam/2
end
