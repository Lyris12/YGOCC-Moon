--Dimenticalgia Stregoneria
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--filters
function cid.tgfilter1(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf45)
		and Duel.IsExistingTarget(cid.tgfilter2,tp,0,LOCATION_MZONE,1,nil,tp)
end
function cid.tgfilter2(c,tp)
	local cl=Duel.GetMatchingGroup(cid.columncheck,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if cl:GetCount()<=0 then return false end
	local check=false
	for ctc in aux.Next(cl) do
		if ctc:GetColumnGroup():IsContains(c) then
			check=true
		end
	end
	return check
end
function cid.columncheck(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf45)
end
function cid.rfilter(c)
	return not c:IsReason(REASON_REDIRECT)
end
function cid.spfilter(c,e,tp)
	return c:GetFlagEffectLabel(id)==e:GetLabel()
		and c:GetReasonPlayer()==tp
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,c:GetPreviousControler())
		and Duel.GetLocationCount(c:GetPreviousControler(),LOCATION_MZONE)>0
end
function cid.checkzone(c,tp)
	return c:GetPreviousControler()==tp
end
--Activate
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(cid.tgfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,cid.tgfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if g1:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=Duel.SelectTarget(tp,cid.tgfilter2,tp,0,LOCATION_MZONE,1,1,nil,tp)
		if g2:GetCount()>0 then
			g1:Merge(g2)
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),PLAYER_ALL,LOCATION_MZONE)
		end
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	local rg=g:Filter(Card.IsRelateToEffect,nil,e)
	if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		local rg=og:Filter(cid.rfilter,nil)
		if #rg==0 then return end
		local fid=e:GetHandler():GetFieldID()
		for oc in aux.Next(rg) do
			if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2,fid)
			else
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1,fid)
			end
		end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetCondition(cid.spcon)
		e1:SetOperation(cid.spop)
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,1)
		end
		Duel.RegisterEffect(e1,tp)
	end
end
--special summon back to the field
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)<=0
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft={}
	ft[1]=Duel.GetLocationCount(tp,LOCATION_MZONE)
	ft[2]=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp)
	if (ft[1]<=0 and ft[2]<=0) or #tg==0 then return end
	local g=Group.CreateGroup()
	g:KeepAlive()
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then 
		local gg=tg:Select(tp,1,1,nil)
		g:Merge(gg)
	else
		for tgp=0,1 do
			local pzg=tg:Filter(cid.checkzone,nil,tgp)
			local czone=pzg:GetCount()
			if ft[tgp+1]<czone then
				czone=ft[tgp]
			end
			local gg=pzg:Select(tp,czone,czone,nil)
			g:Merge(gg)
		end
	end
	if #g>0 then
		for tc in aux.Next(g) do
			Duel.SpecialSummon(tc,0,tp,tc:GetPreviousControler(),false,false,POS_FACEUP)
		end
	end
end