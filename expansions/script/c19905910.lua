--MMS - Mistica Mostruosa Sorgente
--Script by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(id,1,0)
	c:Activate()
	--Excavate
	c:Ignition(0,CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE,EFFECT_FLAG_PLAYER_TARGET,LOCATION_SZONE,true,
		nil,
		aux.LabelCost,
		s.target,
		s.activate
	)
	--fusion summon
	c:Ignition(4,CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE,EFFECT_FLAG_PLAYER_TARGET,LOCATION_SZONE,1,
		nil,
		aux.InfoCost,
		aux.ExcavateTarget(5),
		s.fsop
	)
end

function s.rmfilter(c)
	return c:IsSetCard(0xd71) and c:IsType(TYPE_MONSTER+TYPE_ST) and c:IsAbleToRemoveAsCost()
end
function s.gcheck(g,sg,tp)
	return sg:IsExists(Card.IsAbleToHand,1,g) and sg:IsExists(Card.IsAbleToRemove,3,g,tp,POS_FACEDOWN)
end
function s.filter(c,typ)
	return c:IsType(typ) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local fg=g:Filter(s.rmfilter,nil)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		local cg=Group.CreateGroup()
		local res= #g>=6 and #fg>=3 and fg:CheckSubGroup(s.gcheck,3,3,g,tp)
		cg:DeleteGroup()
		return res
	end
	e:SetLabel(0)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.HintMessage(tp,HINTMSG_REMOVE)
	local sg=fg:SelectSubGroup(tp,s.gcheck,false,3,3,g,tp)
	if #sg>0 and Duel.Remove(sg,POS_FACEUP,REASON_COST)>0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		if e:IsActivated() then
			local c=e:GetHandler()
			og:KeepAlive()
			local e1=Effect.CreateEffect(c)
			e1:Desc(5)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.aclimit)
			e1:SetLabelObject(og)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			for tc in aux.Next(og) do
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_OATH)
				e2:SetCode(EFFECT_CANNOT_TRIGGER)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
		--
		local b1=og:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
		local b2=og:IsExists(Card.IsType,1,nil,TYPE_SPELL)
		local b3=og:IsExists(Card.IsType,1,nil,TYPE_TRAP)
		if not b1 and not b2 and not b3 then return end
		local opt=aux.Option(id,tp,1,b1,b2,b3)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(3)
		e:SetLabel(opt)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_DECK)
	end
end
function s.aclimit(e,re,tp)
	local g=e:GetLabelObject()
	return g:IsExists(Card.IsCode,1,nil,re:GetHandler():GetCode())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain() then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.GetFieldGroupCount(p,LOCATION_DECK,0)<d then return end
	Duel.ConfirmDecktop(p,d)
	local g=Duel.GetDecktopGroup(p,d)
	local opt=e:GetLabel()
	if not opt then return end
	local list={TYPE_MONSTER,TYPE_SPELL,TYPE_TRAP}
	local typ=list[opt+1]
	if #g>0 then
		Duel.DisableShuffleCheck()
		if g:IsExists(s.filter,1,nil,typ) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
			local sg=g:FilterSelect(p,s.filter,1,1,nil,typ)
			if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_HAND) then
				Duel.ConfirmCards(1-p,sg)
				Duel.ShuffleHand(p)
				g:Sub(sg)
			end
		end
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT+REASON_REVEAL)
	end
end

function s.matfilter(c,tp)
	return c:IsCanBeFusionMaterial() and c:IsAbleToRemove(tp,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
end
function s.fusfilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xd71) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain() then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.GetFieldGroupCount(p,LOCATION_DECK,0)<d then return end
	Duel.ConfirmDecktop(p,d)
	local g=Duel.GetDecktopGroup(p,d)
	if #g>0 then
		Duel.DisableShuffleCheck()
		local chkf=p
		local mg1=g:Filter(s.matfilter,nil,p)
		local sg1=Duel.GetMatchingGroup(s.fusfilter,p,LOCATION_EXTRA,0,nil,e,p,mg1,nil,chkf)
		local mg3=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(p)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg3=fgroup(ce,e,p)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(s.fusfilter,p,LOCATION_EXTRA,0,nil,e,p,mg3,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)
			local tg=sg:Select(p,1,1,nil)
			local tc=tg:GetFirst()
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(p,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(p,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				g:Sub(mat1)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,p,p,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(p,tc,mg3,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,p,tc,mat2)
			end
			tc:CompleteProcedure()
		end
		if #g>0 then
			Duel.SortDecktop(p,p,#g)
			for i=1,#g do
				local mg=Duel.GetDecktopGroup(p,1)
				Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
			end
		end
	end
end