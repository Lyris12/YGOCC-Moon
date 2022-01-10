--Psychostizia Informatore
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--pandemonium
	aux.AddOrigPandemoniumType(c)
	--activate
	local p1=Effect.CreateEffect(c)
	p1:GLString(0)
	p1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:SetCondition(s.actcon)
	p1:SetTarget(s.acttg)
	p1:SetOperation(s.actop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_PANDEMONIUM+TYPE_EFFECT,false,false,1,false,true)
	--disrupt hand
	local p2=Effect.CreateEffect(c)
	p2:GLString(1)
	p2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	p2:SetType(EFFECT_TYPE_QUICK_O)
	p2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	p2:SetCode(EVENT_FREE_CHAIN)
	p2:SetRange(LOCATION_SZONE)
	p2:SetCountLimit(1,id)
	p2:SetCondition(aux.PandActCheck)
	p2:SetTarget(s.sctg)
	p2:SetOperation(s.scop)
	c:RegisterEffect(p2)
	--big bang
	local e2=Effect.CreateEffect(c)
	e2:GLString(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.bbcon)
	e2:SetTarget(s.bbtg)
	e2:SetOperation(s.bbop)
	c:RegisterEffect(e2)
	--activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+200)
	e3:SetCost(s.spcost2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) and aux.PandActCheck(e) and s.acttg(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2c2,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,1200,1750,3,RACE_PSYCHO,ATTRIBUTE_LIGHT)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
	or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x2c2,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,1200,1750,3,RACE_PSYCHO,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM)
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end

function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp) and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local typ=Duel.AnnounceType(tp)
	local truetype=(typ==0) and TYPE_MONSTER or (typ==1) and TYPE_SPELL or TYPE_TRAP
	e:SetLabel(truetype)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,0)
end
function s.tdfilter(c,typ)
	return c:IsType(typ) and c:IsAbleToDeck()
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local h=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #h<=0 then return end
	local typ=e:GetLabel()
	Duel.ConfirmCards(1-p,h)
	local g=h:Filter(s.tdfilter,nil,typ)
	if g:GetCount()==0 then return end
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct==0 then return end
	Duel.ShuffleDeck(p)
	Duel.BreakEffect()
	Duel.Draw(p,ct,REASON_EFFECT)
end

function s.bbfilter(c,e,tp,mg)
	if not c:IsType(TYPE_BIGBANG) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) or Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local et=global_card_effect_table[c]
	for _,e in ipairs(et) do
		if e:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=e:GetValue()
			local ec=e:GetCondition()
			if ev and (aux.GetValueType(ev)=="function" and ev(ef,c)&340==340 or ev&340==340) and (not ec or ec(e,c,mg,Group.FromCards(e:GetHandler()))) then return true end
		end
	end
	return false
end
function s.bbcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase(1-tp)
end
function s.bbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE,0,nil,RACE_PSYCHO)
		return #mg>0 and mg:IsContains(e:GetHandler()) and Duel.IsExistingMatchingCard(s.bbfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.bbop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE,0,nil,RACE_PSYCHO)
	if #mg<=0 or not mg:IsContains(e:GetHandler()) then return end
	local g=Duel.GetMatchingGroup(s.bbfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
	if g:GetCount()>0 then
		local eid=e:GetFieldID()
		for tc in aux.Next(mg) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1,eid)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetTargetRange(0xff,0xff)
		e1:SetTarget(s.limitmat)
		e1:SetLabel(eid)
		e1:SetValue(1)
		--
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_MUST_BE_BIGBANG_MATERIAL)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_PLAYER_TARGET)
		e2:SetRange(0xff)
		e2:SetTargetRange(1,1)
		e2:SetLabelObject(e:GetHandler())
		e2:SetValue(1)
		bigbang_limit_mats_operation = e1
		bigbang_force_mats_operation = e2
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummonRule(tp,sg:GetFirst())
		if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
	end
end
function s.limitmat(e,c)
	return c:GetFlagEffect(id)<=0 or c:GetFlagEffectLabel(id)~=e:GetLabel()
end

function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x2c2) and c:IsDestructable(e,REASON_COST,tp)
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_COST)
	end
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>=1 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0
	and e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsPandemoniumActivatable(tp,tp,true,false,false,false,eg,ep,ev,re,r,rp) and r&REASON_EFFECT==0
    and Duel.SelectYesNo(tp,aux.Stringid(id,4))	then
		Duel.BreakEffect()
		aux.PandAct(e:GetHandler())(e,tp,eg,ep,ev,re,r,rp)
		local te=e:GetHandler():GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		local tep=e:GetHandler():GetControler()
		local cost=te:GetCost()
		if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
	end
end