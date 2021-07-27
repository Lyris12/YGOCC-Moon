--Stellarius, Divine-Eye's Corruption
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCost(s.announcecost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	--Shuffle pop, quick effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(aux.exccon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.filter2(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_CONTINUOUS) and c:IsFaceup()
end
function s.filter22(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.filter3(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false) and c:IsCode(997695)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter22,tp,LOCATION_ONFIELD,0,nil)
    local gg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and g:GetClassCount(Card.GetCode)>=3 and gg:GetClassCount(Card.GetCode)>=3 
			and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<-3 then return end
	local g=Duel.GetMatchingGroup(s.filter22,tp,LOCATION_ONFIELD,0,nil)
	local gg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 and gg:GetClassCount(Card.GetCode)>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g2:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g3=g:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg1=gg:Select(tp,1,1,nil)
		gg:Remove(Card.IsCode,nil,gg1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg2=gg:Select(tp,1,1,nil)
		gg:Remove(Card.IsCode,nil,gg2:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg3=gg:Select(tp,1,1,nil)
		g1:Merge(g2)
		g1:Merge(g3)
		g1:Merge(gg1)
		g1:Merge(gg2)
		g1:Merge(gg3)
		Duel.SendtoGrave(g1,REASON_EFFECT+REASON_FUSION)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g4=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g4:GetFirst()
			if tc then
			tc:SetMaterial(g1)
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
			local g=Duel.GetMatchingGroup(s.actfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tc2=g:Select(tp,1,1,nil,tp)
			local tc=tc2:GetFirst()
			if tc then
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			if bit.band(tpe,TYPE_FIELD)~=0 and not tc:IsType(TYPE_FIELD) and not tc:IsFacedown() then
				local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
				if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
				if fc then Duel.Destroy(fc,REASON_RULE) end
				fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			else
				fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			end
		end
			if tc:IsType(TYPE_CONTINUOUS) then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
			tc:CancelToGrave(false) 
		end
			elseif tc:IsType(TYPE_FIELD) then
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
			tc:CancelToGrave(false) 
			end	
		end
			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			Duel.BreakEffect()
			local fg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if fg then
			local etc=fg:GetFirst()
			while etc do
				etc:CreateEffectRelation(te)
			etc=fg:GetNext()
					end
			end
				if op then op(te,tp,eg,ep,ev,re,r,rp) end
				tc:ReleaseEffectRelation(te)
				if etc then	
					etc=fg:GetFirst()
					while etc do
						etc:ReleaseEffectRelation(te)
						etc=g:GetNext()
					end
				end
			end		
		end 
	end
end

function s.filter33(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,true,false) and c:IsCode(997730)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter22,tp,LOCATION_ONFIELD,0,nil)
    local gg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and g:GetClassCount(Card.GetCode)>=2 and gg:GetClassCount(Card.GetCode)>=2 
			and Duel.IsExistingMatchingCard(s.filter33,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<-2 then return end
	local g=Duel.GetMatchingGroup(s.filter22,tp,LOCATION_ONFIELD,0,nil)
	local gg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_ONFIELD,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 and gg:GetClassCount(Card.GetCode)>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g2=g:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg1=gg:Select(tp,1,1,nil)
		gg:Remove(Card.IsCode,nil,gg1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local gg2=gg:Select(tp,1,1,nil)
		g1:Merge(g2)
		g1:Merge(gg1)
		g1:Merge(gg2)
		Duel.SendtoGrave(g1,REASON_EFFECT+REASON_FUSION)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g4=Duel.SelectMatchingCard(tp,s.filter33,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g4:GetFirst()
			if tc then
			tc:SetMaterial(g1)
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
			tc:CompleteProcedure()
		end
			local g=Duel.GetMatchingGroup(s.actfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tc2=g:Select(tp,1,1,nil,tp)
			local tc=tc2:GetFirst()
			if tc then
			local tpe=tc:GetType()
			local te=tc:GetActivateEffect()
			local tg=te:GetTarget()
			local co=te:GetCost()
			local op=te:GetOperation()
			e:SetCategory(te:GetCategory())
			e:SetProperty(te:GetProperty())
			Duel.ClearTargetCard()
			if bit.band(tpe,TYPE_FIELD)~=0 and not tc:IsType(TYPE_FIELD) and not tc:IsFacedown() then
				local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
				if Duel.IsDuelType(DUEL_OBSOLETE_RULING) then
				if fc then Duel.Destroy(fc,REASON_RULE) end
				fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			else
				fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
				if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			end
		end
			if tc:IsType(TYPE_CONTINUOUS) then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
			tc:CancelToGrave(false) 
		end
			elseif tc:IsType(TYPE_FIELD) then
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			if tc and tc:IsFacedown() then Duel.ChangePosition(tc,POS_FACEUP) end
			Duel.Hint(HINT_CARD,0,tc:GetCode())
			tc:CreateEffectRelation(te)
			if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
			tc:CancelToGrave(false) 
			end	
		end
			if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
			if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
			Duel.BreakEffect()
			local fg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if fg then
			local etc=fg:GetFirst()
			while etc do
				etc:CreateEffectRelation(te)
			etc=fg:GetNext()
					end
			end
				if op then op(te,tp,eg,ep,ev,re,r,rp) end
				tc:ReleaseEffectRelation(te)
				if etc then	
					etc=fg:GetFirst()
					while etc do
						etc:ReleaseEffectRelation(te)
						etc=g:GetNext()
					end
				end
			end		
		end 
	end
end
function s.actfilter(c,tp)
	return ((c:IsSetCard(0x12D9) and c:IsType(TYPE_CONTINUOUS)) or c:IsCode(997680)) and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.tdfilter(c,tp)
	return c:IsSetCard(0x12D9) and c:IsType(TYPE_FUSION+TYPE_XYZ) and c:IsAbleToDeck()
	 and ((c:IsLocation(LOCATION_MZONE) and c:IsFaceup()) or c:IsLocation(LOCATION_GRAVE))
end
function s.desfilter1(c)
	return c:IsFaceup() and c:IsDestructable()
end
function s.desfilter2(c)
	return c:IsDestructable()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_MZONE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		local g2=Duel.GetMatchingGroup(s.desfilter1,tp,LOCATION_SZONE,0,nil)
		local g3=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_ONFIELD,nil)
		if #g2>0 and #g3>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		local tc1=g2:Select(tp,1,1,s.desfilter1)
		local tc2=g3:Select(tp,1,1,s.desfilter2)
		tc1:Merge(tc2)
		Duel.Destroy(tc1,REASON_EFFECT)
		end
	end
end
