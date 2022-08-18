EFFECT_CANNOT_HAVE_CHROMA_MATERIAL	=779
TYPE_CHROMA							=0x1000000000000
TYPE_CUSTOM							=TYPE_CUSTOM|TYPE_CHROMA
CTYPE_CHROMA						=0x10000
CTYPE_CUSTOM						=CTYPE_CUSTOM|CTYPE_CHROMA

REASON_CHROMA						=0x1000000000

--Custom Type Table
Auxiliary.Chromas={} --number as index = card, card as index = function() is_ritual

--overwrite functions
local get_type, get_orig_type, get_prev_type_field, get_reason = 
	Card.GetType, Card.GetOriginalType, Card.GetPreviousTypeOnField, Card.GetReason

Card.GetType=function(c,scard,sumtype,p)
	local tpe=scard and get_type(c,scard,sumtype,p) or get_type(c)
	if Auxiliary.Chromas[c] then
		tpe=tpe|TYPE_CHROMA
		if not Auxiliary.Chromas[c]() then
			tpe=tpe&~TYPE_RITUAL
		end
	end
	return tpe
end
Card.GetOriginalType=function(c)
	local tpe=get_orig_type(c)
	if Auxiliary.Chromas[c] then
		tpe=tpe|TYPE_CHROMA
		if not Auxiliary.Chromas[c]() then
			tpe=tpe&~TYPE_RITUAL
		end
	end
	return tpe
end
Card.GetPreviousTypeOnField=function(c)
	local tpe=get_prev_type_field(c)
	if Auxiliary.Chromas[c] then
		tpe=tpe|TYPE_CHROMA
		if not Auxiliary.Chromas[c]() then
			tpe=tpe&~TYPE_RITUAL
		end
	end
	return tpe
end
Card.GetReason=function(c)
	local rs=get_reason(c)
	local rc=c:GetReasonCard()
	if rc and Auxiliary.Chromas[rc] then
		rs=rs|REASON_CHROMA
	end
	return rs
end

--Custom Functions
function Card.IsCanBeChromaMaterial(c,mc)
	if mc:IsFacedown() then return false end
	local tef2={mc:IsHasEffect(EFFECT_CANNOT_HAVE_CHROMA_MATERIAL)}
	for _,te2 in ipairs(tef2) do
		if te2:GetValue()(te2,c) then return false end
	end
	return true
end
function Auxiliary.AddOrigChromaType(c,isritual)
	table.insert(Auxiliary.Chromas,c)
	Auxiliary.Customs[c]=true
	local isritual=isritual==nil and false or isritual
	Auxiliary.Chromas[c]=function() return isritual end
end
function Auxiliary.AddChromaProc(c,f)
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local ge2=Effect.CreateEffect(c)
	ge2:SetType(EFFECT_TYPE_FIELD)
	ge2:SetCode(EFFECT_SPSUMMON_PROC_G)
	ge2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge2:SetRange(LOCATION_HAND)
	ge2:SetCondition(Auxiliary.ChromaCondition(f))
	ge2:SetOperation(Auxiliary.ChromaOperation(f))
	ge2:SetValue(14)
	c:RegisterEffect(ge2)
end
function Auxiliary.CMaterialFilter(c,e,tp,g,cc,f)
	local sg,mg=Group.FromCards(cc),Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	return not c:IsType(TYPE_CHROMA) and (not f or f(c))
		and mg:IsExists(Auxiliary.CConditionFilter,1,sg,e,tp,sg,mg,c)
end
function Auxiliary.CConditionFilter(c,e,tp,sg,mg,mat)
	sg:AddCard(c)
	local res=Auxiliary.ChromaGoal(sg,e,tp,mat)
		or mg:IsExists(Auxiliary.CConditionFilter,1,sg,e,tp,sg,mg,mat)
	sg:RemoveCard(c)
	return res
end
function Card.GetIndicatorValue(c)
	local lv=c:GetLevel()
	local rk=c:GetRank()
	local lk=c:GetLink()
	local st=c:GetStage()
	local sb=c:GetStability()
	local fr=c:GetFuture()
	local cl=c:GetCell()
	return (lv>0 and lv) or (rk>0 and rk) or (st>0 and st)
		or (sb>0 and sb) or (fr>0 and fr)
		or (cl>0 and cl) or Duel.ReadCard(c,CARDDATA_LEVEL)
end
function Auxiliary.ChromaGoal(sg,e,tp,mat)
	local ct=#sg
	return ct>1 and Duel.GetUsableMZoneCount(tp)>ct-1
		and (mat:GetIndicatorValue()==sg:GetSum(Card.GetIndicatorValue)
			or mat:GetAttack()<=sg:GetSum(Card.GetAttack)
			or mat:GetDefense()<=sg:GetSum(Card.GetDefense))
		and sg:IsExists(Auxiliary.ChromaCheck,ct,nil,mat,e,tp)
end
function Auxiliary.ChromaCheck(c,mat,e,tp)
	return c:IsType(TYPE_CHROMA) and (c:IsAttribute(mat:GetAttribute()) or c:IsRace(mat:GetRace()))
		and c:IsCanBeSpecialSummoned(e,14,tp,true,true) and not c:IsForbidden() and c:IsCanBeChromaMaterial(mat)
end
function Auxiliary.ChromaCondition(f)
	return	function(e,c,og)
				if c==nil then return true end
				local tp=c:GetControler()
				local g=nil
				if og then
					g=og:Filter(Card.IsLocation,nil,LOCATION_MZONE)
				else
					g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
				end
				return g:IsExists(Auxiliary.CMaterialFilter,1,nil,e,tp,g,c,f)
			end
end
function Auxiliary.ChromaOperationCheck(ft)
	return	function(g)
				return #g<=ft
			end
end
function Auxiliary.ChromaOperation(f)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				local tg=nil
				if og then
					tg=og:Filter(Card.IsLocation,nil,LOCATION_MZONE)
				else
					tg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local tc=tg:Select(tp,Auxiliary.CMaterialFilter,1,1,nil,e,tp,tg,c,f):GetFirst()
				local ft=Duel.GetUsableMZoneCount(tp)
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
				local smg=Group.FromCards(c)
				local mg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
				Duel.SetSelectedCard(smg)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				Auxiliary.GCheckAdditional=Auxiliary.ChromaOperationCheck(ft)
				local g=mg:SelectSubGroup(tp,Auxiliary.ChromaGoal,true,2,math.min(#mg,ft),e,tp,tc)
				Auxiliary.GCheckAdditional=nil
				if not g then return end
				Duel.HintSelection(Group.FromCards(tc))
				Duel.SendtoGrave(tc,REASON_MATERIAL+REASON_CHROMA)
				tc:SetMaterial(g)
				sg:Merge(g)
			end
end
