--Psychostizia Gendarme
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--bigbang
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,s.proton,1,1,s.electron,1,1)
	c:EnableReviveLimit()
	--cannot be targeted
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--set pande
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(s.setcon)
	e4:SetCost(s.setcost)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
function s.proton(c)
	return c:IsRace(RACE_PSYCHO) and c:GetVibe()==1
end
function s.electron(c)
	return c:IsSetCard(0x2c2) and c:GetVibe()==-1
end

function s.rmcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	if #g~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local tc1=g:Select(tp,1,1,nil):GetFirst()
		if tc1 and Duel.Remove(tc1,tc1:GetPosition(),REASON_EFFECT+REASON_TEMPORARY)>0 and tc1:IsLocation(LOCATION_REMOVED) then
			local fid=c:GetFieldID()
			local ct1=(Duel.GetCurrentPhase()==PHASE_END) and 2 or 1
			tc1:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_SET_AVAILABLE,ct1,fid)
			local rg1=Group.FromCards(tc1)
			rg1:KeepAlive()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(rg1)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			e1:SetReset(RESET_PHASE+PHASE_END,ct1)
			Duel.RegisterEffect(e1,tp)
			g:RemoveCard(tc1)
			if #g>0 and Duel.Remove(g,g:GetFirst():GetPosition(),REASON_EFFECT+REASON_TEMPORARY)>0 and g:GetFirst():IsLocation(LOCATION_REMOVED) then
				local tc2=g:GetFirst()
				local ct2=(Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN2) and 2 or 1
				tc2:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN2+RESET_SELF_TURN,EFFECT_FLAG_SET_AVAILABLE,ct2,fid)
				g:KeepAlive()
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
				e1:SetCountLimit(1)
				e1:SetLabel(fid)
				e1:SetLabelObject(g)
				e1:SetCondition(s.retcon2)
				e1:SetOperation(s.retop)
				e1:SetReset(RESET_PHASE+PHASE_MAIN2+RESET_SELF_TURN,ct2)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.retfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.retcon2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTurnPlayer()~=tp then return false end
	return s.retcon(e,tp,eg,ep,ev,re,r,rp)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil,e:GetLabel())
	g:DeleteGroup()
	local tc=sg:GetFirst()
	while tc do
		if tc:IsPreviousLocation(LOCATION_FZONE) then
			Duel.MoveToField(tc,tp,tc:GetPreviousControler(),LOCATION_FZONE,tc:GetPreviousPosition(),true)
		else
			Duel.ReturnToField(tc)
		end
		tc=sg:GetNext()
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x2c2) and c:IsType(TYPE_TRAP) and c:IsDestructable(e,REASON_COST,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,tp)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.Destroy(g,REASON_COST)
	end
end
function s.filter(c,tp)
	return c:IsSetCard(0x2c2) and c:IsType(TYPE_PANDEMONIUM) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and aux.PandSSetCon(c,tp,true)() and not c:IsForbidden()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=(e:GetLabel()==1) or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,tp))
		e:SetLabel(0)
		return res
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,1601)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if tc then
		aux.PandSSet(tc,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,Group.FromCards(tc))
	end
end