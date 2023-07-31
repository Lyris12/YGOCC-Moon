--Elegant Iceflower Tuning
--Elegante Sintonizzazione del Fiordighiaccio
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate up to 3 of these effects (you cannot activate the same effect twice, and you resolve them in the listed order, skipping any that were not chosen);
	● Special Summon from your Deck, 1 monster with the same current name, or original name, as a face-up monster on the field.
	● Target 1 face-up monster on the field; choose 1 other monster on the field, and the name of either monster becomes the name of the other.
	● Choose 1 monster on the field. It can be treated as a Tuner if used as Synchro Material this turn.
	Then, unless you activated all 3 of the above effects, you can apply this effect.
	● Immediately after this effect resolves, Synchro Summon 1 Synchro Monster, using monsters on either field, but all with the same name.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
--FE1
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(false,s.codefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,{c:GetCode()},{c:GetOriginalCodeRule()})
end
function s.codefilter(c,codes,ogcodes)
	return c:IsFaceup() and (c:IsCode(table.unpack(codes)) or c:IsOriginalCodeRule(table.unpack(ogcodes)))
end
function s.nmfilter(c,tp)
	return c:IsFaceup() and Duel.IsExists(false,s.notcodefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,{c:GetCode()})
end
function s.notcodefilter(c,codes)
	if not c:IsFaceup() then return false end
	for _,code in ipairs(codes) do
		if not c:IsCode(code) then
			return true
		end
	end
	return false
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and s.nmfilter(chkc,tp)
	end
	local b1 = Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b2 = Duel.IsExists(true,s.nmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	local b3 = Duel.IsExists(false,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then
		return b1 or b2 or b3
	end
	local tab={b1,b2,b3}
	local opt=0
	for i=1,3 do
		if tab[i] and Duel.SelectYesNo(tp,aux.Stringid(id,i)) then
			opt=opt|(1<<(i-1))
			if i==1 then
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
			elseif i==2 then
				e:SetProperty(EFFECT_FLAG_CARD_TARGET)
				Duel.Select(HINTMSG_FACEUP,true,tp,s.nmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
			end
		end
	end
	e:SetLabel(opt)
	if opt&2==0 then
		e:SetProperty(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lab=e:GetLabel()
	local brk=false
	local success=false
	if lab&1==1 and Duel.GetMZoneCount(tp)>0 then
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			brk=true
			success=true
		end
	end
	if lab&2==2 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsFaceup() then
			if brk then
				Duel.BreakEffect()
				brk=false
			end
			local g=Duel.Select(aux.Stringid(id,6),false,tp,s.notcodefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,{tc:GetCode()})
			if #g>0 then
				brk=true
				success=true
				local pair=Group.FromCards(tc,g:GetFirst())
				Duel.HintMessage(tp,aux.Stringid(id,4))
				local sg=pair:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				local sc=sg:GetFirst()
				pair:RemoveCard(sc)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_CODE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				e1:SetValue(pair:GetFirst():GetCode())
				sc:RegisterEffect(e1)
			end
		end
	end
	if lab&4==4 then
		if brk then
			Duel.BreakEffect()
			brk=false
		end
		local g=Duel.Select(HINTMSG_FACEUP,false,tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			brk=true
			success=true
			Duel.HintSelection(g)
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(STRING_CAN_BE_TREATED_AS_TUNER)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_TUNER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			e1:SetValue(1)
			g:GetFirst():RegisterEffect(e1)
		end
	end
	if success and lab<7 then
		Duel.AdjustAll()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetValue(1)
		Duel.RegisterEffect(e1,tp)
		local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:CheckSubGroup(s.gcheck,2,#g,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.HintMessage(tp,HINTMSG_SMATERIAL)
			local mg=g:SelectSubGroup(tp,s.gcheck,false,2,#g,tp)
			if #mg>0 then
				local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,nil,mg)
				if #sg>0 then
					local e0=Effect.CreateEffect(c)
					e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
					e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
					e0:SetCode(EVENT_SPSUMMON)
					e0:SetOperation(function(_e)
						if aux.GetValueType(e1)=="Effect" then
							e1:Reset()
						end
						_e:Reset()
					end
					)
					Duel.RegisterEffect(e0,tp)
					Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
					return
				end
			end
		end
		e1:Reset()
	end
end
function s.gcheck(g,tp)
	if g:GetClassCount(Card.GetCode)~=1 then return false end
	local effects={}
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_MUST_BE_SMATERIAL)
		if tc:IsControler(tp) then
			e1:SetTargetRange(1,0)
		else
			e1:SetTargetRange(0,1)
		end
		tc:RegisterEffect(e1)
		table.insert(effects,e1)
	end
	local res=Duel.IsExists(false,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,g)
	for _,e in ipairs(effects) do
		e:Reset()
	end
	return res
end