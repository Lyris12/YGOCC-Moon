--created & coded by Lyris
--F・HERO・オーガナイゼーション
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabel(0)
	e2:SetCost(function(e) e:SetLabel(100) return true end)
	e2:SetTarget(cid.cptg)
	e2:SetOperation(cid.cpop)
	c:RegisterEffect(e2)
end
function cid.filter(c)
	return c:IsSetCard(0xf7a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cid.cpfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsType(TYPE_SPELL) or not c:IsAbleToRemoveAsCost() then return false end
	for _,ef in pairs(global_card_effect_table[c]) do
		local tg=ef:GetTarget()
		if ef:IsHasCategory(CATEGORY_FUSION_SUMMON) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) then return true end
	end
	return false
end
function cid.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(cid.sumlimit)
		Duel.RegisterEffect(e1,tp)
		local res=aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsExistingMatchingCard(cid.cpfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
		e1:Reset()
		return res
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.sumlimit)
	Duel.RegisterEffect(e1,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,cid.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	e1:Reset()
	Duel.Remove(Group.FromCards(tc,c),POS_FACEUP,REASON_COST)
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
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function cid.cpop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function cid.sumlimit(e,c,sp,st,spos,tp,te)
	return st==SUMMON_TYPE_FUSION and not c:IsSetCard(0xf7a)
end
